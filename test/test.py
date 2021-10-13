from pyml_example import random_expr, evaluate, random_expr_, evaluate_, map_array
import timeit
import numpy as np

# Manipulating AST encodings is a bit dirty but not unworkable
def evaluate_bis(e):
    h, args = e
    if h == 'Const':
        return args[0]
    elif h == 'Binop':
        lhs, (op, _), rhs = args
        lhs = evaluate_bis(lhs)
        rhs = evaluate_bis(rhs)
        if op == 'Add':
            return lhs + rhs
        elif op == 'Mul':
            return lhs * rhs

def test_evaluate(n=100, depth=2):
    for i in range(n):
        e = random_expr(depth)
        assert evaluate(e) == evaluate_bis(e)

def profile(n=10_000, depth=5):
    t = timeit.Timer(lambda: evaluate(random_expr(depth))).timeit(n) / n
    t_ = timeit.Timer(lambda: evaluate_(random_expr_(depth))).timeit(n) / n
    t_bis = timeit.Timer(lambda: evaluate_bis(random_expr(depth))).timeit(n) / n
    print(f"Bis     {t_bis*1e6:4.0f}us")
    print(f"Normal  {t*1e6:4.0f}us")
    print(f"Capsule {t_*1e6:4.0f}us")

def test_map():
    arr = np.array([1.0, 2.0], dtype=np.double)
    map_array(lambda x: 2*x + 1, arr)
    assert np.all(arr == np.array([3.0, 5.0]))

if __name__ == "__main__":
    test_evaluate()
    test_map()
    profile()