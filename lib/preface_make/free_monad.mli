(** Modules for building {!Preface_specs.FREE_MONAD} modules. *)

(** {1 Tutorial}

    In order to be modular, [Preface] offers multiple way to build a
    {!Preface_specs.FREE_MONAD}. In many case, you just have to use the
    parametrized module {!Over_functor}, but in some particular cases, you want
    to be able to create ir from an [Applicative] or another [Monad]

    {2 Basics}

    The most common way to build a [Free_monad] is to use the module
    {!Over_functor}.

    {2 A complete example}

    In this example we propose to define a Store where strings can be store and
    retrieved with a key which is also a string.

    {3 Defining a [Functor]}

    The first piece of this jigsaw should be an Algebraic Data Type (ADT) and it's
    dedicated [map] function. In language like Haskell such map function can be
    automatically derived. In [Preface] this is not the case yet.

    The type definition here is an ADT and not a Generalized ADT, because it uses
    an embedded visitor and the application of the Yoneda lemma to make it isomorphic
    to the corresponding.

    {[
      (* file: store.ml *)
      module Store = struct
        type 'a t =
          | Get of (string * (string option -> 'a))
          | Set of (string * string * (unit -> 'a))

        module Functor = Preface_make.Functor.Via_map (struct
          type nonrec 'a t = 'a t

          let map f x =
            match x with
            | Get (k, r) -> Get (k, (fun s -> f (r s)))
            | Set (k, v, r) -> Set (k, v, (fun () -> f (r ())))
          ;;
        end)
      end
    ]}

    {3 Creating the [Free_monad]}

    Thanks to the [Preface] library the corresponding [Free_monad] you be
    simply created using the parametric module `Over_functor`.

    {[
      module StoreFree = Preface_make.Free_monad.Over_functor (StoreFunctor)
    ]}

    {3 Defining one interpet}

    Then we can propose one interpretation using an OCaml side effect for instance.

    {[
      let runStore l = function
        | Store.Get (k, f) ->
          f (Option.map snd (List.find_opt (fun (k', _) -> k' = k) !l))
        | Store.Set (k, v, f) ->
          let () = l := (k, v) :: !l in
          f ()
      ;;
    ]}

    Now we propose two operations i.e. [set] and [get]. This operations are
    reified thanks to the ADT definition. Reification here means a [set] (resp. [get])
    operation is denoted by the constructor [Set] (resp. [Get]) thanks to the [liftF]
    function which create a data of the [Free_monad] from a data from the [Functor].

    {[
      let get k = StoreFree.liftF (Store.Get (k, id))
      let set k v = StoreFree.liftF (Store.Set (k, v, id)))
    ]}

    {3 Using the [Free_monad]}

    We can now, with this material, create and run programs. For the program creation
    since a [Free_monad] is a Preface [Monad], we can used langage extensions like
    [let*] for a syntetic and expressive program definition. For this purpose the
    corresponding module should be opened.

    Finally the interpret can be executed with the [run] functions defined in the
    generated [Free_monad] module.

    {[
      let program =
        let open StoreFree.Syntax in
        let* () = set "k1" "v1" in
        get "k1"
      ;;

      let l = ref [] in
      StoreFree.run (runStore l) program
    ]}

    {2 Conclusion}

    [Preface] makes it possible to construct free monads in several different
    ways. In addition, [liftF] and [run] capabilities are provided for the
    interpretation layer. *)

(** {2 Constructors} *)

(** Incarnation of a [Free_monad] from a [Functor] *)
module Over_functor (F : Preface_specs.FUNCTOR) :
  Preface_specs.FREE_MONAD with type 'a f = 'a F.t

(** Incarnation of a [Free_monad] from an [Applicative] *)
module Over_applicative (F : Preface_specs.APPLICATIVE) :
  Preface_specs.FREE_MONAD with type 'a f = 'a F.t

(** Incarnation of a [Free_monad] from a [Monad] *)
module Over_monad (F : Preface_specs.MONAD) :
  Preface_specs.FREE_MONAD with type 'a f = 'a F.t
