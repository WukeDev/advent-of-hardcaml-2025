open Core
open Hardcaml

let run_test filename =
  (* 1. Read and parse the file into a list of (is_left, amount) *)
  let instructions = 
    In_channel.read_lines filename 
    |> List.filter_map ~f:(fun line ->
        let line = String.strip line in
        if String.is_empty line then None
        else 
          try
            let is_left = Char.equal line.[0] 'L' in
            (* MODULO 100: Ensure software integer is 0-99 *)
            let raw_dist = String.drop_prefix line 1 |> Int.of_string in
            let amount = raw_dist % 100 in 
            Some (is_left, amount)
          with _ -> None)
  in

  (* 2. Setup the Simulator *)
  let module Sim = Cyclesim.With_interface (HW.I) (HW.O) in
  let sim = Sim.create HW.create in
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in

  (* 3. Hardware Reset (Initializes position to 50) *)
  inputs.reset := Bits.vdd; (* Bits.one *)
  Cyclesim.cycle sim;
  inputs.reset := Bits.gnd; (* Bits.zero *)

  (* 4. Main Simulation Loop *)
  List.iter instructions ~f:(fun (is_left, amt) ->
    (* Set inputs for this cycle *)
    inputs.enable  := Bits.vdd;
    inputs.is_left := if is_left then Bits.vdd else Bits.gnd;
    
    (* Convert the 0-99 integer to a 8-bit hardware signal *)
    inputs.amount  := Bits.of_int_trunc ~width:8 amt;

    (* Trigger one clock cycle *)
    Cyclesim.cycle sim;

    (* Debug: See how the hardware is reacting *)
    Stdio.printf "Input: %s%d | Pos: %d | Total: %d\n" 
      (if is_left then "L" else "R") 
      amt
      (Bits.to_int_trunc !(outputs.pos))
      (Bits.to_int_trunc !(outputs.out));
  );

  (* 5. Finalize *)
  inputs.enable := Bits.gnd;
  Cyclesim.cycle sim;
  
  Stdio.printf "Final Hardware 'Out' Value: %d\n" (Bits.to_int_trunc !(outputs.out))

let () = run_test "day01/input.txt"