def check_string(string):
    dic = {'{': 0, '}': 0, '[': 0, ']': 0, '(': 0, ')': 0}
    for s in string:
        dic[s] += 1
        if dic['{'] < dic['}'] or dic['['] < dic[']'] or dic['('] < dic[')']:
            return False
    if dic['{'] != dic['}'] or dic['['] != dic[']'] or dic['('] != dic[')']:
        return False
    else:
        return True
examples = ['[{}({})]', '{]', '{', '{[}]', '}{']
for example in examples:
    print(example, check_string(example))
