import copy
import json
import sys

class std:
    returned = None
    @staticmethod
    def readline():
        return sys.stdin.readline().strip()

    def stop(arg):
        std.returned = True
        print(arg)

def exec_rule(rule, scope, fields):
    stmts = rule['Then']
    scope_before = {}
    for field in fields:
        scope_before[field] = copy.deepcopy(scope.get(field))
    print(f"Executing rule: {rule['If']}")
    exec(stmts, scope)
    for field in fields:
        changed = True
        if scope_before.get(field) == scope.get(field):
            changed = False

        if changed:
            print("  {:<20}{} -> {}".format(
                field+":",
                repr(scope_before.get(field)),
                repr(scope.get(field)),
            ))
        else:
            print("  {:<20}{} (unchanged)".format(
                field+":",
                repr(scope.get(field)),
            ))

def main():
    filename = sys.argv[1]
    with open(filename, 'r') as f:
        state_machines = json.load(f)
        # print(json.dumps(state_machines, indent=4))

    scope = {
        'std': std,
    }

    for state_machine in state_machines:
        fields = state_machine['Fields']
        for rule in state_machine['Rules']:
            if rule['If'] == 'BEGIN':
                stmts = rule['Then']
                exec_rule(rule, scope, fields)

    state_machine = state_machines[0]
    i = 0
    while not scope['std'].returned:
        i += 1
        print()
        print(f"Step {i}:")
        fields = state_machine['Fields']
        scope = {k: v for k, v in scope.items() if k in fields}

        matching_rules = []
        for rule in state_machine['Rules']:
            cond = rule['If']
            if cond == 'BEGIN':
                continue
            is_matched = eval(cond, scope)
            if is_matched:
                matching_rules.append(rule)
        if not matching_rules:
            print("Error: No matching rule found")
            for field in fields:
                if field == 'std':
                    continue
                print("  {:<20}{}".format(
                    field+":",
                    repr(scope.get(field)),
                ))
            break

        # for rule in matching_rules:
        #     exec_rule(rule, scope, fields)
        if len(matching_rules) > 1:
            print("Error: Multiple matching rules found")
            for rule in matching_rules:
                print(" -", rule['If'])
            break
        rule = matching_rules[0]
        exec_rule(rule, scope, fields)

main()
