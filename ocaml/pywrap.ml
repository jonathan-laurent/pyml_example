open Base
open Python_lib
open Python_lib.Let_syntax

(* //////////////////////////////////////////////////////////////////////////////////// *)

type binop = [%import: Expr.binop] [@@deriving python]

(* We use @with because Base.python_of_int is not in scope *)
type expr = [%import: Expr.expr [@with Base.int := int]] [@@deriving python]

let expr =
  Defunc.Of_python.create
    ~type_name:"expr"
    ~conv:expr_of_python

let python_of_expr_capsule, expr_capsule_of_python =
  Py.Capsule.make "expr"

let expr_capsule =
  Defunc.Of_python.create
    ~type_name:"expr_capsule"
    ~conv:expr_capsule_of_python

let evaluate =
  let%map_open e = positional "e" expr ~docstring:"expression to evaluate" in
  python_of_int (Expr.eval e)

let random_expr =
  let%map_open n = positional "n" int ~docstring:"deph of the expression to generate" in
  python_of_expr (Expr.random_expr n)

let evaluate_ =
  let%map_open e = positional "e" expr_capsule ~docstring:"" in
  python_of_int (Expr.eval e)

let random_expr_ =
  let%map_open n = positional "n" int ~docstring:"" in
  python_of_expr_capsule (Expr.random_expr n)

(* //////////////////////////////////////////////////////////////////////////////////// *)

let float_array_of_python = Numpy.to_bigarray Float64 C_layout

let python_of_float_array = Numpy.of_bigarray

let float_array =
  Defunc.Of_python.create
    ~type_name:"float array"
    ~conv:float_array_of_python

let float_float_fun_of_python f x =
  let f = Py.Callable.to_function f in
  float_of_python (f ([|python_of_float x|]))

let float_float_function =
  Defunc.Of_python.create
    ~type_name:"float -> float"
    ~conv:float_float_fun_of_python

let genarray_indices t =
  let open Bigarray.Genarray in
  let rec aux i =
    if i < 0 then [[]]
    else
      let k = nth_dim t i in
      List.concat_map (aux (i-1)) ~f:(fun idx ->
        List.init k ~f:(fun i -> i::idx)) in
  aux (num_dims t - 1)
  |> List.map ~f:Array.of_list

let map_array = 
  let%map_open f = positional "f" float_float_function ~docstring:""
  and t = positional "arr" float_array ~docstring:"" in
  List.iter (genarray_indices t) ~f:(fun idx ->
    let open Bigarray.Genarray in
    set t idx (f (get t idx)));
  Py.none

(* //////////////////////////////////////////////////////////////////////////////////// *)

let () =
  if not (Py.is_initialized ()) then Py.initialize ();
  let mod_ = Py_module.create "example_module" in
  Py_module.set mod_ "evaluate"
    ~docstring:"Evaluate an expression to an integer." evaluate;
  Py_module.set mod_ "random_expr"
    ~docstring:"Generate a random expression." random_expr;
  Py_module.set mod_ "evaluate_"
    ~docstring:"" evaluate_;
  Py_module.set mod_ "random_expr_"
    ~docstring:"" random_expr_;
  Py_module.set mod_ "map_array"
    ~docstring:"Apply a function to every element of an array in place" map_array;
