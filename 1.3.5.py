def bin_mult(s1, s2):
    return format(int(s1, 2) * int(s2, 2), 'b')
examples = [('101', '11'), ('100', '111'), ('1011', '1110')]
for example in examples:
    print(' * '.join(example), '=', bin_mult(*example))
