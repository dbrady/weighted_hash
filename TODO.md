# TODO

- [x] Ability to build hash of key1: weight1, key2: weight2
- [x] Ability to sample hash and get weighted probabilities
- [ ] Large-scale demo script (run 10M times and show weighted output
  matches weighted inputs)
- [x] Nested hashes key1: {... }  the weight for this hash is the
  TOTAL weight of the hash. E.g. key1: 4.0, key2: { key3: 2.0, key4:
  2.0 }} the nested hash has a weight of 4.0 and the outer hash has a
  total weight of 8.0.
- [x] Arbitrarily scale the weight of nested hashes? E.g. {a: 1, b: 1,
  c: { d: 1, e: 1}}, but we want c to have a total weight of 1
  (e.g. a,b,c each get 1/3, which means d and e each get 0.5 total.
- [x] Test against multiple same keys -- should add up


# Fun For Later

- [ ] Some kind of shuffle/pop syntax? Where we can remove items
  iteratively?
