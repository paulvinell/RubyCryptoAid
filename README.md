# RubyCryptoAid
Support for solving basic cryptography exercises in Ruby

## Examples

### Cryptopals set 1, challenge 1
[Link to exercise](https://cryptopals.com/sets/1/challenges/1)

```
irb(main):002:0> "49276d206b696c6c696e6720796f757220627261696e206c696b6520612070
6f69736f6e6f7573206d757368726f6f6d".hex_to_raw => a
=> nil
irb(main):003:0> a.value
=> "I'm killing your brain like a poisonous mushroom"
irb(main):004:0> a.to_b64
=> "SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t"
```

### Cryptopals set 1, challenge 2
[Link to exercise](https://cryptopals.com/sets/1/challenges/2)

```
irb(main):005:0> "1c0111001f010100061a024b53535009181c".hex_to_raw => a
=> nil
irb(main):006:0> "686974207468652062756c6c277320657965".hex_to_raw => b
=> nil
irb(main):007:0* (a ^ b) => c
=> nil
irb(main):008:0> c.value
=> "the kid don't play"
irb(main):009:0> c.to_hex
=> "746865206b696420646f6e277420706c6179"
```
