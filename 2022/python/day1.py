max_ = 0

with open("../rust/input/day1_a") as f:
    sum_ = 0
    for line in f.readlines():
        if line == "\n":
            if sum_ > max_:
                max_ = sum_
            sum_ = 0
        else:
            sum_ = sum_ + int(line)

print(max_)
