// Texto que se va a pintar en el HTML con javascript

const asdf = 4

const msg = "Texto procedente de JavaScript"

document.getElementById("myTeexamplet").innerHTML = msg;

console.log(msg)

var example = {
    baz_: 0,
    foo_: 1,
    calc: function() {
        return this.foo_ + this.baz_;
    }
};
example.bar_ = 2;
example["baz_"] = 3;
console.log(example.calc());

// stuff.js
var o = {
    "foo": 1,
    bar: 3,
};
o.foo += o.bar;
console.log(o.foo);