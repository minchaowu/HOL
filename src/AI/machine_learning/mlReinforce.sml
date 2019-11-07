(* ========================================================================= *)
(* FILE          : mlReinforce.sml                                           *)
(* DESCRIPTION   : Environnement for reinforcement learning                  *)
(* AUTHOR        : (c) Thibault Gauthier, Czech Technical University         *)
(* DATE          : 2019                                                      *)
(* ========================================================================= *)

structure mlReinforce :> mlReinforce =
struct

open HolKernel Abbrev boolLib aiLib psMCTS psBigSteps 
mlTreeNeuralNetwork smlParallel

val ERR = mk_HOL_ERR "mlReinforce"

(* -------------------------------------------------------------------------
   Training
   ------------------------------------------------------------------------- *)

type schedule = (int,real) list

type 'a tnnguider_param =
  {
  term_of_board: 'a -> term,
  schedule: schedule
  }

fun random_dhtnn_gamespec tnnguider_param gamespec =
  random_dhtnn dhtnn_param 

   (#dim , length (#movel gamespec)) (#operl gamespec)

fun train_tnnguider tnnguider_param exl =
  


fun epex_stats epex =
  let
    val d = count_dict (dempty Term.compare) (map #1 epex)
    val r = average_real (map (Real.fromInt o snd) (dlist d))
  in
    summary ("examples: " ^ its (length epex));
    summary ("average duplicates: " ^ rts r)
  end



fun train_dhtnn_gamespec gamespec epex =
  let
    val _ = epex_stats epex
    val schedule = [(!nepoch_glob, !lr_glob]
    val dhtnn = random_dhtnn_gamespec gamespec
  in
    train_dhtnn (!ncore_train_glob,!batchsize_glob) dhtnn epex schedule
  end

fun train_f gamespec allex =
  let val (dhtnn,t) = add_time (train_dhtnn_gamespec gamespec) allex in
    summary ("Training time : " ^ rts t); dhtnn
  end

(* specific guider for a specific game *)
(* fun mk_tnnguider1 gamespec =
  {
  operl = 
  nlayer_oper, nlayer_headp, nlayer_heade,
  dimin,
  dimout,
  nntm_of_board,
  schedule
  }  
*)

fun mk_uniformguider gamespec =
  
fun mk_randomguider gamerspec

datatype ('a,'b) guider = 
  RandomGuider | UniformGuider | TnnGuider of ('a,'b) 
  
  mk_gamedhtnn : ('a 'b) dhtnnguider_param -> dhtnn
  train_gamedhtnn : ('a 'b) dhtnnguider_param -> 'a ex -> dhtnn
  mk_fep : ('a,'b) gamespec -> dhtnn -> ('a,'b) psMCTS.guider
  

type rl_param =
  {
  (* search *)
  ncore_bigsteps_glob
  ntarget_compete_elim : int,
  ntarget_compete_final : int,
  bigsteps_compete : guider_env -> ('a,'b) bigsteps_param,
  ntarget_explore : int,
  bigsteps_explore : guider_env -> ('a,'b) bigsteps_param,
  (* examples *)
  exwindow_glob : int,
  uniqex_flag : bool,
  (* generation *)
  ngen : int,
  level_start : int,
  level_threshold : real
  }

(*
(* mcts parameters *)
val ncore_mcts_glob = ref 8
(* training parameters *)
val dim_glob = ref 8
val batchsize_glob = ref 64
val nepoch_glob = ref 100
val lr_glob = ref 0.1
val ncore_train_glob = ref 4
(* default parameters *)
val ngen = ref 20
val ntarget_compete = ref 400
val ntarget_explore = ref 400

val exwindow_glob = ref 40000
val uniqex_flag = ref false
val dim_glob = ref 8
val batchsize_glob = ref 64
val nepoch_glob = ref 100
val lr_glob = ref 0.1
val ncore_train_glob = ref 4
val ncore_mcts_glob = ref 8
val level_start = ref 1
val level_threshold = ref 0.75

type ('a,'b) gamespec =
  {
  movel : 'b list,
  move_compare : 'b * 'b -> order,
  string_of_move : 'b -> string,
  filter_sit : 'a -> (('b * real) list -> ('b * real) list),
  status_of : ('a -> psMCTS.status),
  apply_move : ('b -> 'a -> 'a),
  operl : (term * int) list,
  nntm_of_sit: 'a -> term,
  mk_targetl: int -> int -> 'a list,
  write_targetl: string -> 'a list -> unit,
  read_targetl: string -> 'a list,
  max_bigsteps : 'a -> int
  }
*)

(* -------------------------------------------------------------------------
   Training
   ------------------------------------------------------------------------- *)


type 'a ex = ('a * real list * real list)
type dhtnn = mlTreeNeuralNetwork.dhtnn
type flags = bool * bool * bool
type 'a extgamespec =
  (flags * dhtnn, 'a, bool * dhex) smlParallel.extspec

(* -------------------------------------------------------------------------
   Log
   ------------------------------------------------------------------------- *)

val logfile_glob = ref "mlReinforce"
val eval_dir = HOLDIR ^ "/src/AI/experiments/eval"
fun log_eval file s =
  let val path = eval_dir ^ "/" ^ file in
    mkDir_err eval_dir;
    append_endline path s
  end
fun summary s = (log_eval (!logfile_glob) s; print_endline s)

(* -------------------------------------------------------------------------
   Hard-coded parameters
   ------------------------------------------------------------------------- *)

fun summary_rl_param rl_param =
  let
    val file  = "  file: " ^ (!logfile_glob)
    val para  = "parallel_dir: " ^ (!parallel_dir)
    val gen1  = "gen max: " ^ its (!ngen_glob)
    val gen2  = "target_compete: " ^ its (!ntarget_compete)
    val gen3  = "target_explore: " ^ its (!ntarget_explore)
    val gen4  = "starting level: " ^ its (!level_start)
    val gen5  = "level threshold: " ^ rts (!level_threshold)
    val nn0   = "uniqex_flag: " ^ bts (!uniqex_flag)
    val nn1   = "example_window: " ^ its (!exwindow_glob)
    val nn2   = "nn dim: " ^ its (!dim_glob)
    val nn3   = "nn batchsize: " ^ its (!batchsize_glob)
    val nn4   = "nn epoch: " ^ its (!nepoch_glob)
    val nn6   = "nn lr: " ^ rts (!lr_glob)
    val nn5   = "nn ncore: " ^ its (!ncore_train_glob)
    val mcts2 = "mcts simulation: " ^ its (!nsim_glob)
    val mcts3 = "mcts decay: " ^ rts (!decay_glob)
    val mcts4 = "mcts ncore: " ^ its (!ncore_mcts_glob)
    val mcts5 = "mcts exploration coeff: " ^ rts (!exploration_coeff)
    val mcts6 = "mcts noise alpha: " ^ rts (!alpha_glob)
    val mcts7 = "mcts temp: " ^ bts (!temp_flag)
  in
    summary "Global parameters";
    summary (String.concatWith "\n  "
     ([file,para] @
      [gen1,gen2,gen3,gen4,gen5] @
      [nn0,nn1,nn2,nn3,nn4,nn6,nn5] @
      [mcts2,mcts3,mcts4,mcts5,mcts6,mcts7])
     ^ "\n")
  end

(* -------------------------------------------------------------------------
   Creating guidance for MCTS by producing an evaluation and policy for
   each board (sit).
   ------------------------------------------------------------------------- *)


(* -------------------------------------------------------------------------
   Examples
   ------------------------------------------------------------------------- *)

val emptyallex = []




(* -------------------------------------------------------------------------
   External parallelization specification
   ------------------------------------------------------------------------- *)

fun bstatus_to_string b = if b then "win" else "lose"
fun string_to_bstatus s = assoc s [("win",true),("lose",false)]
  handle HOL_ERR _ => raise ERR "string_to_bstatus" ""

fun string_to_bool s =
   if s = "true" then true
   else if s = "false" then false
   else raise ERR "string_to_bool" ""

fun flags_to_string (b1,b2,b3) = bts b1 ^ " " ^  bts b2 ^ " " ^ bts b3
fun string_to_flags s =
  triple_of_list (map string_to_bool (String.tokens Char.isSpace s))

fun write_param file (flags,dhtnn) =
  (writel (file ^ "_flags") [flags_to_string flags];
   write_dhtnn (file ^ "_dhtnn") dhtnn)

fun read_param file =
  ((string_to_flags o hd o readl) (file ^ "_flags"),
   read_dhtnn (file ^ "_dhtnn"))

fun write_result file (bstatus,exl) =
  (
  writel (file ^ "_bstatus") [bstatus_to_string bstatus];
  write_dhex (file ^ "_exl") exl
  )

fun read_result file =
  let
    val bstatus = (string_to_bstatus o hd o readl) (file ^ "_bstatus")
    val dhex = read_dhex (file ^ "_exl")
  in
    app remove_file [file ^ "_bstatus",file ^ "_exl"];
    (bstatus,dhex)
  end

fun reflect_globals () =
  "(" ^ String.concatWith "; "
  [
  "mlReinforce.nsim_glob := " ^ its (!nsim_glob),
  "mlReinforce.decay_glob := " ^ rts (!decay_glob),
  "mlReinforce.dim_glob := " ^ its (!dim_glob),
  "psMCTS.alpha_glob := " ^ rts (!alpha_glob),
  "psMCTS.exploration_coeff := " ^ rts (!exploration_coeff)
  ]
  ^ ")"

fun n_bigsteps_extern (gamespec: ('a,'b) gamespec) (flags,dhtnn) target =
  let
    val (noise,bstart,btemp) = flags
    val _ = temperature_flag := btemp
    val (mctsparam : ('a,'b) mctsparam) =
      {nsim = !nsim_glob, decay = !decay_glob, noise = noise,
       status_of = #status_of gamespec,
       apply_move = #apply_move gamespec,
       fevalpoli = mk_guider_dhtnn bstart gamespec dhtnn}
    val (bstatus,exl,rootl) = n_bigsteps gamespec mctsparam target
  in
    (bstatus,exl)
  end

fun mk_extspec (name: string) (gamespec : ('a,'b) gamespec) =
  {
  self = name,
  reflect_globals = reflect_globals,
  function = n_bigsteps_extern gamespec,
  write_param = write_param,
  read_param = read_param,
  write_argl = #write_targetl gamespec,
  read_argl = #read_targetl gamespec,
  write_result = write_result,
  read_result = read_result
  }

(* -------------------------------------------------------------------------
   Final test
   ------------------------------------------------------------------------- *)

fun test_n_bigsteps_extern gamespec dhtnn target =
  let
    val _ = temperature_flag := false
    val mctsparam =
      {nsim = !nsim_glob, decay = !decay_glob, noise = false,
       status_of = #status_of gamespec,
       apply_move = #apply_move gamespec,
       fevalpoli = mk_guider_dhtnn false gamespec dhtnn}
    val (bstatus,_,rootl) = n_bigsteps gamespec mctsparam target
  in
    (target,bstatus,length rootl)
  end

fun test_write_result gamespec file (target,bstatus,plength) =
  (
  #write_targetl gamespec (file ^ "_target") [target];
  writel (file ^ "_bstatus") [bstatus_to_string bstatus];
  writel (file ^ "_plength") [its plength]
  )

fun test_read_result gamespec file =
  let
    val target = hd (#read_targetl gamespec (file ^ "_target"))
    val bstatus = (string_to_bstatus o hd o readl) (file ^ "_bstatus")
    val plength = (string_to_int o hd o readl) (file ^ "_plength")
  in
    app remove_file [file ^ "_target",file ^ "_bstatus",file ^ "_plength"];
    (target,bstatus,plength)
  end

fun test_write_param file dhtnn = write_dhtnn (file ^ "_dhtnn") dhtnn
fun test_read_param file = read_dhtnn (file ^ "_dhtnn")

fun test_mk_extspec (name: string) (gamespec: ('a,'b) gamespec) =
  {
  self = name,
  reflect_globals = reflect_globals,
  function = test_n_bigsteps_extern gamespec,
  write_param = test_write_param,
  read_param = test_read_param,
  write_argl = #write_targetl gamespec,
  read_argl = #read_targetl gamespec,
  write_result = test_write_result gamespec,
  read_result = test_read_result gamespec
  }

fun test_compete extspec (dhtnn:dhtnn) targetl =
  let
    val ncore = !ncore_mcts_glob
    val (l,t) = add_time (parmap_queue_extern ncore extspec dhtnn) targetl
  in
    print_endline ("Testing time : " ^ rts t); l
  end


(* -------------------------------------------------------------------------
   Competition
   ------------------------------------------------------------------------- *)

fun compete_one extspec dhtnn targetl =
  let
    val flags = (false,false,false)
    val param = (flags,dhtnn)
    val ncore = !ncore_mcts_glob
    val (l,t) = add_time (parmap_queue_extern ncore extspec param) targetl
    val nwin = length (filter fst l)
  in
    summary ("Competition time : " ^ rts t); nwin
  end
(*
fun compete_guider guiderspec targetl =
  let
    val flags = (false,false,false)
    val param = (flags,dhtnn)
    val ncore = !ncore_mcts_glob
    val (l,t) = add_time (parmap_queue_extern ncore extspec param) targetl
    val nwin = length (filter fst l)
  in
    summary ("Competition time : " ^ rts t); nwin
  end
*)

fun summary_compete (w_old,w_new) =
  let val s = if w_new >= w_old then "Passed" else "Failed" in
    summary (s ^ ": " ^ its w_old ^ " " ^ its w_new)
  end

fun level_up b =
  if b then (incr level_start; summary ("Level up: " ^ its (!level_start)))
  else ()

fun compete (gamespec,extspec) dhtnn_old dhtnn_new =
  let
    val targetl = #mk_targetl gamespec (!level_start) (!ntarget_compete)
    val _ = summary ("Competition targets: " ^ its (length targetl))
    val w_old = compete_one extspec dhtnn_old targetl
    val w_new = compete_one extspec dhtnn_new targetl
    val freq = int_div (Int.max (w_new,w_old)) (length targetl)
  in
    summary_compete (w_old,w_new);
    summary ("Max percentage: " ^ rts (approx 3 freq));
    level_up (freq > !level_threshold);
    if w_new >= w_old then dhtnn_new else dhtnn_old
  end

(* -------------------------------------------------------------------------
   Exploration
   ------------------------------------------------------------------------- *)

fun explore startb (gamespec,extspec) allex dhtnn =
  let
    val targetl = #mk_targetl gamespec (!level_start) (!ntarget_explore)
    val _ = summary ("Exploration targets: " ^ its (length targetl))
    val flags = (true,startb,!temp_flag)
    val param = (flags,dhtnn)
    val (l,t) =
      add_time (parmap_queue_extern (!ncore_mcts_glob) extspec param) targetl
    val nwin = length (filter fst l)
    val exll = map snd l
    val _ = summary ("Exploration time: " ^ rts t)
    val _ = summary ("Exploration wins: " ^ its nwin)
    fun cmp ((a,_,_),(b,_,_)) = Term.compare (a,b)
    val exl1 = List.concat exll @ allex
    val exl2 = if !uniqex_flag then mk_sameorder_set cmp exl1 else exl1
    val b = int_div nwin (length targetl) > !level_threshold
  in
    level_up b; (b, first_n (!exwindow_glob) exl2)
  end

(* -------------------------------------------------------------------------
   Standalone functions for testing
   ------------------------------------------------------------------------- *)

fun mcts_test nsim gamespec dhtnn startsit =
  let
    val param =
      {nsim = nsim, decay = 1.0, noise = false,
       status_of = #status_of gamespec,
       apply_move = #apply_move gamespec,
       fevalpoli = mk_guider_dhtnn false gamespec dhtnn}
  in
    mcts param (starttree_of param startsit)
  end

fun mcts_uniform nsim gamespec startsit =
  let
    val param =
      {nsim = nsim, decay = 1.0, noise = false,
       status_of = #status_of gamespec,
       apply_move = #apply_move gamespec,
       fevalpoli = mk_guider_uniform gamespec}
  in
    mcts param (starttree_of param startsit)
  end

fun n_bigsteps_test gamespec dhtnn target =
  let
    val status_of = #status_of gamespec
    val mctsparam =
      {nsim = !nsim_glob, decay = !decay_glob, noise = false,
       status_of = #status_of gamespec,
       apply_move = #apply_move gamespec,
       fevalpoli = mk_guider_dhtnn false gamespec dhtnn}
    val _ = verbose_flag := true
    val (_,_,rootl) = n_bigsteps gamespec mctsparam target
    val _ = verbose_flag := false
  in
    rootl
  end

(* -------------------------------------------------------------------------
   Reinforcement learning loop
   ------------------------------------------------------------------------- *)

fun rl_start (gamespec,extspec) =
  let
    val _ = remove_file (eval_dir ^ "/" ^ (!logfile_glob))
    val _ = summary_param ()
    val _ = summary "Generation 0"
    val prefile = eval_dir ^ "/" ^ (!logfile_glob) ^ "_gen" ^ its 0
    val dhtnn_random = random_dhtnn_gamespec gamespec
    val (_,allex) = explore true (gamespec,extspec) emptyallex dhtnn_random
    val dhtnn = train_f gamespec allex
  in
    write_dhtnn (prefile ^ "_dhtnn") dhtnn;
    write_dhex (prefile ^ "_allex") allex;
    (allex, dhtnn)
  end

fun rl_one n (gamespec,extspec) (allex,dhtnn) =
  let
    val prefile = eval_dir ^ "/" ^ (!logfile_glob) ^ "_gen" ^ its n
    val _ = summary ("\nGeneration " ^ its n)
    val dhtnn_new = train_f gamespec allex
    val dhtnn_best = compete (gamespec,extspec) dhtnn dhtnn_new
    val _ = write_dhtnn (prefile ^ "_dhtnn") dhtnn_best
    fun loop exl =
      let val (b,newexl) = explore false (gamespec,extspec) exl dhtnn_new in
        if b then loop newexl else newexl
      end
    val newallex = loop allex
  in
    write_dhex (prefile ^ "_allex") newallex;
    (newallex,dhtnn_best)
  end

fun rl_loop (n,nmax) (gamespec,extspec) rldata =
  if n >= nmax then rldata else
  let val rldata_new = rl_one n (gamespec,extspec) rldata in
    rl_loop (n+1, nmax) (gamespec,extspec) rldata_new
  end

fun start_rl_loop (gamespec,extspec) =
  let val (allex,dhtnn) = rl_start (gamespec,extspec) in
    rl_loop (1,!ngen_glob) (gamespec,extspec) (allex,dhtnn)
  end


end (* struct *)
