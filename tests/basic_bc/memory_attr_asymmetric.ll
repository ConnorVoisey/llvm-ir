; Exercises the LLVM 21+ encoding of the `memory` attribute, where `errnomem`
; was inserted as location 2 and `other` (the default) moved from bits 4-5 to
; bits 6-7. The effects are deliberately different per location so that a
; decoder reading the wrong bits produces visibly wrong values.
; Encoded value: other=Read(01) errnomem=NoModRef(00) inaccessiblemem=Mod(10) argmem=Ref(01) = 0x49

declare void @asymmetric() memory(read, inaccessiblemem: write, errnomem: none)

define void @caller() {
  call void @asymmetric()
  ret void
}
