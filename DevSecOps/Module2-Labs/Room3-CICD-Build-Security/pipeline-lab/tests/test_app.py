def test_addition():
    assert 1 + 1 == 2

def test_string():
    assert "pipeline" in "pipeline security"

def test_flag_awareness():
    # A developer who knows about PPE
    dangerous_patterns = ["eval(", "exec(", "os.system(", "subprocess.call("]
    code = open("Makefile").read()
    for pattern in dangerous_patterns:
        assert pattern not in code, f"Dangerous pattern found: {pattern}"
