# milliForth
A FORTH in an ever decreasing number of bytes, currently 352 — the smallest real programming language ever, as of yet.

## bytes?

Yes, bytes.  This is a FORTH so small it fits in a 512-byte boot sector.  This isn't new — both sectorFORTH[^1] and miniforth[^2][ successfully fit a FORTH within the boot sector.  However, milliFORTH appears to be *the smallest* "real"[^3] programming language implementation ever, beating out sectorLISP[^4], a 436 byte implementation of LISP, by an ever increasing number of bytes (currently 84).

## Language

sectorFORTH[^1] was an extensive guide throughout the process of implementing milliFORTH, and milliFORTH's design actually converged on sectorFORTH unintentionally in a few areas.  That said, the language implemented is intentionally very similar, being the 'minimal FORTH'.

FORTH itself will not be explained here (prior understanding assumed).  Being so small, milliFORTH contains just a handful of words:

| Word | Signature | Function |
| ---- | --------- | -------- |
| `@` | `( addr -- value )` | Get a value at an address |
| `!` | `( value addr -- )` | Store a value at an address |
| `sp@` | `( -- sp )` | Get pointer to top of the data stack |
| `rp@` | `( -- rp )` | Get pointer to top of the return stack |
| `0#` | `( value -- flag )` | Check if a value differs from zero (-1 = TRUE, 0 = FALSE) |
| `+` | `( a b -- a+b )` | Sum two numbers |
| `nand` | `( a b -- aNANDb )` | NAND two numbers |
| `exit` | `( r:addr -- )` | Pop from the return stack, resume execution at the popped address |
| `,` | `( a -- )` | Store the top of the data stack into the top of the dictionary, advancing the pointer |
| `key` | `( -- key )` | Read a keystroke |
| `:` | `( -- )` | Begin a colon definition, set the state to compilation |
| `;` | `( -- )` | End a colon definition, set the state to interpretation |
| `emit` | `( char -- )` | Print out an ASCII character |
| `s@` | `( -- s@ )` | The "state struct" pointer.  The cells of this struct are, in order: <ul><li>`state`: The state of the interpreter (0 = compile words, 1 = execute words)</li><li>`>in`: Pointer to the current offset into the terminal input buffer</li><li>`latest`: The pointer to the most recent dictionary space</li><li>`here`: The pointer to the next available space in the dictionary</li></ul> |

On a fundamental level, milliFORTH is almost the same FORTH as implemented by sectorFORTH:

- All of the interpreter state words are bundled into a single struct (`s@`).
- Words don't get hidden while you are defining them.  This doesn't really hinder your actual ability to write programs, but rather makes it possible to hang the interpreter if you do something wrong in this respect.
- There's no terminal input buffer, as such. Words are accepted and acted upon as soon as a space (or CR) is typed.
- Error handling is even sparser.  Successful input results in nothing (no familiar `ok.`).  Erroneous input prints character 19 between the previous input and the next prompt.

## Use

sector.bin is an assembled binary of sector.asm.  You can run it using `make emulate`, which invokes (and thus requires) `qemu-system-i386`, or by using any emulator of your choice.

Alternatively, `make` will reassemble sector.asm, then run the above qemu emulator; and `make bochs` will run it in the `bochs` emulator, which thamesynne finds more useful for debugging.

**Included in this repo is a pyautogui script** which can be run to automatically type in the `hello_world.FORTH` file into your qemu emulator.  A very useful tool.  It is self-explaining, but usage involves simply starting the QEMU emulator, running the python script, and putting your cursor into the QEMU emulator again.

`make sizecheck` is a utility which assembles sector.asm into sector.bin and then lists out the size of sector.bin for you.  Note that this automatically removes the padding from the .bin (as a working bootloader must be exactly 512 bytes).

## References
[^1]: The immensely inspirational sectorForth, to which much credit is due: https://github.com/cesarblum/sectorforth/.
[^2]: https://github.com/meithecatte/miniforth/.
[^3]: "Real" excludes esolangs and other non-production languages. For example, the sectorLISP author's implementation of BF is just 99 bytes, but it clearly isn't used to any serious capacity.
[^4]: The mind-blowing sectorLISP: https://justine.lol/sectorlisp2/, https://github.com/jart/sectorlisp.
