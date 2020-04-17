(** A [Free_monad] allows you to build a monad from a given functor. Such monad
    is equiped with two additional functions: one dedicated to the creation of a
    new data and another one for the interpretation. *)

(** {1 Structure anatomy} *)

module type CORE = sig
  type 'a f
  (** The type holded by the [Functor]. *)

  (** The type holded by the [Free_monad]. *)
  type 'a t =
    | Return of 'a
    | Bind of 'a t f

  val liftF : 'a f -> 'a t
  (** Create a new ['a t]. *)

  val run : ('a f -> 'a) -> 'a t -> 'a
  (** Execute a given interpret for given data *)
end

(** {1 API} *)

module type API = sig
  include CORE

  module Functor : Functor.API with type 'a t = 'a t

  module Applicative : Applicative.API with type 'a t = 'a t

  module Monad : Monad.API with type 'a t = 'a t

  include module type of Monad with type 'a t := 'a t
end

(** The complete interface of a [Free_monad]. *)
