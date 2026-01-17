open Hardcaml
open Signal


module I = struct
  type 'a t = {
    clock    : 'a;
    reset    : 'a;
    enable   : 'a;
    is_left  : 'a;      (* 1 for L, 0 for R *)
    amount   : 'a; [@bits 8]
  } [@@deriving sexp_of, hardcaml]
end

module O = struct
  type 'a t = {
    pos : 'a; [@bits 8]
    out : 'a; [@bits 16]
  } [@@deriving sexp_of, hardcaml]
end

let create (inputs : _ I.t) =
  let open Always in
  let spec = Reg_spec.create ~clock:inputs.clock ~clear:inputs.reset () in

  (* Create a position register that resets to 50 and a total that resets to 0 *)
  let position = Variable.reg spec  ~clear_to:(of_unsigned_int ~width:8 50) ~width:8 in
  let total = Variable.reg spec ~width:16 in

  let addition = Variable.wire ~default:(zero 8) ()in
  let subtraction = Variable.wire ~default:(zero 8) ()in
  let valid = Variable.wire ~default:gnd () in


  compile [
    (* Combinatorial Logic *)
    if_ (inputs.is_left) [
      subtraction <-- inputs.amount;
      if_ (position.value.:(7)) [
        addition <--. 0
      ] [
        addition <--. 100
      ];
    ] [
      addition <-- inputs.amount;
      if_ (position.value.:(7)) [
        subtraction <--. 100
      ] [
        subtraction <--. 0
      ];
    ];

    valid <-- (
      (position.value ==:. 0) |: 
      (position.value ==:. 100) |: 
      (position.value ==:. 200)
    );

    (* Sequential Logic *)
    if_ (valid.value) [
      total <-- total.value +:. 1
    ] [];

    position <-- position.value -: subtraction.value +: addition.value
  ];
  { O.pos = position.value; O.out = total.value;}
