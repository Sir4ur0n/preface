module Req = struct
  type 'a t = 'a Preface_stdlib.Validate.t

  let arbitrary x = Preface_qcheck.Arbitrary.validate x

  let observable x = Preface_qcheck.Observable.validate x

  let equal x y = Preface_stdlib.Validate.equal x y
end

module Functor =
  Preface_laws.Functor.Cases (Preface_stdlib.Validate.Functor) (Req)
    (Preface_qcheck.Sample.Pack1)
module Applicative =
  Preface_laws.Applicative.Cases (Preface_stdlib.Validate.Applicative) (Req)
    (Preface_qcheck.Sample.Pack1)
module Monad =
  Preface_laws.Monad.Cases (Preface_stdlib.Validate.Monad) (Req)
    (Preface_qcheck.Sample.Pack1)
module Selective =
  Preface_laws.Selective.Cases (Preface_stdlib.Validate.Selective) (Req)
    (Preface_qcheck.Sample.Pack1)

let cases n =
  [
    ("Validate Functor Laws", Functor.cases n)
  ; ("Validate Applicative Laws", Applicative.cases n)
  ; ("Validate Monad Laws", Monad.cases n)
  ; ("Validate Selective  Monad Laws) Laws", Selective.cases n)
  ]
;;
