# File: julia-execute-functions-async.jl
# Date:     Sun Jul 14 09:05:43 +08 2019 for julia ver 1.1.1
# Modified: Fri Aug 23 21:10:21 +08 2019 for julia ver 1.2.0
# Author  : WRY
# =========================================================
"""
RESULTS EXTRACTED:

1.563118134592168e9 Net total synchronous  (sequential) run_duration = 50.175812959671020 sec. / 50.170111894607544 sec.
1.563118155173762e9 Net total asynchronous (concurrent) run_duration = 20.470710039138794 sec. / 20.436648130416870 sec.

This julia code compares the synchronous and asynchronous execution times (run_durations) of a common shared function named "do_same_work(parameters)". 

There are four(4) tasks to be executed, named as "task1, task2, task3 and task4". Each task will perform the same function, do_same_work(parameters). However, each task will be provided with different input parameters. In this code, we decided on four(4) tasks because we have physically 4-CPU cores on our notebook.  

(1) In the synchronous (sequential) execution, all four(4) tasks  will be executed sequentially (one after another) and the accumulated total time will be the synchronous run_duration. In this mode, the running sequence is (task1 -> task2 -> task3 -> task4) and finish. The individual task durations are additive. From the results above, the total run_duration to finish is about 50 seconds. 

(2) Asynchronous running tasks means independent running tasks, that is, once started the tasks run to completion, without control, coordination or waiting for any event to happen. In this asynchronous (concurrent) execution, all four(4) tasks  will be executed simultaneously. In this mode, all four(4) tasks start at almost the same time, and they execute in overlapping time, one task on each CPU core. Since the tasks are running in parallel, the net completion time taken is the time to finish the longest task. The times are overlapping and so are not additive, meaning the earlier tasks have already finished. From the results above, the longest task took about 20 seconds. 

SOME NOTES.

(N1) Putting macro @async (on function) immediately and automatically starts asynschronous task execution

(N2) Because we display high resolution time in the outputs, we display the start and finish times for all of the four(4) tasks, covering both synchronous and asynchronous execution. 

(N3) We also can sort the results display according to this time. 

(N4) To prove that the calculations are correct, all tasks running in synchronous and asynchronous modes gave the same answers. 

(N5) In the asynchronous case, we can print the time details of the individual tasks (taskname) as they happen, so we can see the overlapping task executions.   

"""

# =========================================================
using Dates 
start_time = Dates.time();

println("=================================================="); 
print(Dates.time()-start_time, " Current date today() = ", Dates.today(), "\n")
print(Dates.time()-start_time, " Current date time now: ", Dates.now(), "\n")
print(Dates.time()-start_time, " Current running program script: ", PROGRAM_FILE, "\n")
print(Dates.time()-start_time, " Bismillah from WRY in Julia script. \n") 
println("==================================================");

using InteractiveUtils
import InteractiveUtils
@show (versioninfo());

println("==================================================");
using PyCall
psutil = pyimport("psutil")
numCPU = psutil.cpu_count()
print(Dates.time()-start_time, " PyCall: Value of psutil.cpu_count() = $numCPU \n")

using Hwloc
topology = Hwloc.topology_load()
counts = Hwloc.histmap(topology)
ncores = counts[:Core]
npus = counts[:PU]
print(Dates.time()-start_time, " Hwloc: This machine has $ncores cores and $npus PUs (processing units). \n")
num_physicalcores = Hwloc.num_physical_cores()
print(Dates.time()-start_time, " Hwloc: This machine has $num_physicalcores physical cores. \n")

# View number of workers + master process
# Create n workers during a session if required
# workers are addressed by numbers (PIDs)
# master process had PID =1, the rest are PID of workers
using Distributed
Distributed.addprocs(4);
my_nprocs = Distributed.nprocs();
print(Dates.time()-start_time, " Number of workers + master process = $my_nprocs \n")
my_wpid = Distributed.workers();
print(Dates.time()-start_time, " List of workers PIDs = $my_wpid \n")
println("==================================================");

# ==========================================================
function do_same_work(	taskname	::Any, 
						init_value	::Real, 
						delta		::Real, 
						time_sleep	::Real, 
						run_time_duration::Real)
# ==========================================================
    result = init_value
    start_fxn_time = time()
 
    # Perform while loop within run_time_duration seconds
    while (time() - start_fxn_time) < run_time_duration  
        result += delta
        sleep(time_sleep)

    ## UNCOMMENT LINE BELOW FOR FULL DETAILS OF CONCURRENT TASK RUNS
	## println(Dates.time()-start_time, " $taskname result = ", result);  
    end 

    return (result) 
end; 

# =========================================================
function run_functions_sequential()
# =========================================================
	
	time_start_task01 = time(); 
    println(Dates.time()-start_time, " Starting function01.");
 	function01 = do_same_work("taskname01", 100, 10, 0.3, 15);
	println(Dates.time()-start_time, " Return value of function01 = ", function01);
	println(Dates.time()-start_time, " Finished function01.");
	println(Dates.time()-start_time, " Sequential task01 run_duration = ", (time() - time_start_task01), " sec.");
	println()


    time_start_task02 = time();	
	println(Dates.time()-start_time, " Starting function02.");
	function02 = do_same_work("taskname02", 10, 10, 0.1, 20);
	println(Dates.time()-start_time, " Return value of function02 = ", function02);
	println(Dates.time()-start_time, " Finished function02.");
	println(Dates.time()-start_time, " Sequential task02 run_duration = ", (time() - time_start_task02), " sec.");
    println()

    time_start_task03 = time();
	println(Dates.time()-start_time, " Starting function03.");
	function03 = do_same_work("taskname03", 50, 5, 0.2, 5); 
	println(Dates.time()-start_time, " Return value of function03 = ", function03);
	println(Dates.time()-start_time, " Finished function03.");
	println(Dates.time()-start_time, " Sequential task03 run_duration = ", (time() - time_start_task03), " sec.");
    println()

    time_start_task04 = time();
	println(Dates.time()-start_time, " Starting function04.");
	function04 = do_same_work("taskname04", 0, 10, 0.5, 10);
	println(Dates.time()-start_time, " Return value of function04 = ", function04);
    println(Dates.time()-start_time, " Finished function04.");
	println(Dates.time()-start_time, " Sequential task04 run_duration = ", (time() - time_start_task04), " sec.");
	println();

    println(Dates.time()-start_time, " Total synchronous (sequential) run_duration = ", (time() - time_start_task01), " sec.");
 	println();
end;

# =========================================================
function run_functions_async()
# =========================================================
   start_async_time = time()

   # NOTE: Putting macro @async (on function) immediately starts task execution

   task01 = @async do_same_work("taskname01", 100, 10, 0.3, 15); sleep(0.1); 
   println(Dates.time()-start_time, " Using @async: istaskstarted(task01) STARTED = ", istaskstarted(task01)); 
   time_start_task01 = time();

   task02 = @async do_same_work("taskname02", 10, 10, 0.1, 20); sleep(0.1);  
   println(Dates.time()-start_time, " Using @async: istaskstarted(task02) STARTED = ", istaskstarted(task02)); 
   time_start_task02 = time();

   task03 = @async do_same_work("taskname03", 50, 5, 0.2, 5);  sleep(0.1); 
   println(Dates.time()-start_time, " Using @async: istaskstarted(task03) STARTED = ", istaskstarted(task03)); 
   time_start_task03 = time();

   task04 = @async do_same_work("taskname04", 0, 10, 0.5, 10); sleep(0.1); 
   println(Dates.time()-start_time, " Using @async istaskstarted(task04) STARTED = ", istaskstarted(task04)); 
   time_start_task04 = time();

   count_finish_task01 = 0
   count_finish_task02 = 0
   count_finish_task03 = 0
   count_finish_task04 = 0

   while (!istaskdone(task01) || !istaskdone(task02) || !istaskdone(task03) || !istaskdone(task04))
	sleep(1)  ## MUST HAVE sleep TO DISPLAY

	# ==============
        if (istaskdone(task01) == true)
                time_finish_task01 = time();
		count_finish_task01 += 1;
	end
	if (istaskdone(task01) == true) && (count_finish_task01 == 1)  # TO PRINT ONCE ONLY
		println()
		println(Dates.time()-start_time, " istaskdone(task01) FINISHED = ", istaskdone(task01)); 
		println(Dates.time()-start_time, " task01 run duration = ", (time_finish_task01 - time_start_task01), " sec."); 
		println(Dates.time()-start_time, " fetch(task01) = ", fetch(task01)); 
		println(Dates.time()-start_time, " Accumulated async run_duration = ", (time() - start_async_time), " sec.");
        end
	# ==============
        if (istaskdone(task02) == true)
		time_finish_task02 = time();
		count_finish_task02 += 1;
	end
	if (istaskdone(task02) == true) && (count_finish_task02 == 1)
		println()
		println(Dates.time()-start_time, " istaskdone(task02) FINISHED = ", istaskdone(task02)); 
		println(Dates.time()-start_time, " task02 run duration = ", (time_finish_task02 - time_start_task02), " sec."); 
		println(Dates.time()-start_time, " fetch(task02) = ", fetch(task02)); 
		println(Dates.time()-start_time, " Accumulated async run_duration = ", (time() - start_async_time), " sec.");
        end
	# ==============
        if (istaskdone(task03) == true)
		time_finish_task03 = time();
		count_finish_task03 += 1
	end
	if (istaskdone(task03) == true) && (count_finish_task03 == 1)
		println()
		println(Dates.time()-start_time, " istaskdone(task03) FINISHED = ", istaskdone(task03));
		println(Dates.time()-start_time, " task03 run duration = ", (time_finish_task03 - time_start_task03), " sec.");  
		println(Dates.time()-start_time, " fetch(task03) = ", fetch(task03)); 
		println(Dates.time()-start_time, " Accumulated async run_duration = ", (time() - start_async_time), " sec."); 
        end
	# ==============
        if (istaskdone(task04) == true)
		time_finish_task04 = time();
		count_finish_task04 += 1
	end
	if (istaskdone(task04) == true) && (count_finish_task04 == 1)
                println()
		println(Dates.time()-start_time, " istaskdone(task04) FINISHED = ", istaskdone(task04)); 
		println(Dates.time()-start_time, " task04 run duration = ", (time_finish_task04 - time_start_task04), " sec."); 
		println(Dates.time()-start_time, " fetch(task04) = ", fetch(task04)); 
		println(Dates.time()-start_time, " Accumulated async run_duration = ", (time() - start_async_time), " sec.");  
        end
	# ==============
    end # end..while   
        
    println();
    println(Dates.time()-start_time, " Total asynchronous (concurrent) run_duration = ", (time() - start_async_time), " sec.");
    println();
end ## end..function

# =========================================================
## MAIN PROGRAM BELOW
# =========================================================

	println(" Run functions synchronously (sequentially)")
	println("==================================================");
	run_functions_sequential() 
	println("==================================================");

	println(" Run functions asynchronously (concurrently)")
	println("==================================================");
	run_functions_async() 
	println("==================================================");

# =========================================================
print(Dates.time()-start_time, " Alhamdulillah from WRY in Julia script. \n\n") 
# =========================================================


"""
===========================================================
EXECUTION RESULTS
===========================================================

(base) wruslan@HPEliteBk8470p-ub1604-64b:~/Documents/julia-codes/0GOOD-JULIA# julia julia-execute-functions-async.jl 
==================================================
0.003929853439331055 Current date today() = 2019-08-24
0.1174628734588623 Current date time now: 2019-08-24T22:32:59.258
0.20985698699951172 Current running program script: julia-execute-functions-async.jl
0.21857595443725586 Bismillah from WRY in Julia script. 
==================================================
Julia Version 1.2.0
Commit c6da87ff4b (2019-08-20 00:03 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
  CPU: Intel(R) Core(TM) i5-3380M CPU @ 2.90GHz
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-6.0.1 (ORCJIT, ivybridge)
Environment:
  JULIA_NUM_THREADS = 4
versioninfo() = nothing
==================================================
5.6474199295043945 PyCall: Value of psutil.cpu_count() = 4 
8.751933813095093 Hwloc: This machine has 2 cores and 4 PUs (processing units). 
8.761262893676758 Hwloc: This machine has 2 physical cores. 
14.454201936721802 Number of workers + master process = 5 
14.459337949752808 List of workers PIDs = [2, 3, 4, 5] 
==================================================
 Run functions synchronously (sequentially)
==================================================
14.689259767532349 Starting function01.
29.79477882385254 Return value of function01 = 600
29.811262845993042 Finished function01.
29.811340808868408 Sequential task01 run_duration = 15.122081995010376 sec.

29.81589698791504 Starting function02.
49.840826988220215 Return value of function02 = 1990
49.8409538269043 Finished function02.
49.841009855270386 Sequential task02 run_duration = 20.025113821029663 sec.

49.841110944747925 Starting function03.
54.872365951538086 Return value of function03 = 175
54.8724799156189 Finished function03.
54.87252187728882 Sequential task03 run_duration = 5.031412839889526 sec.

54.87260699272156 Starting function04.
64.9038097858429 Return value of function04 = 200
64.90393877029419 Finished function04.
64.90399885177612 Sequential task04 run_duration = 10.031392812728882 sec.

64.90410280227661 Total synchronous (sequential) run_duration = 50.214845180511475 sec.

==================================================
 Run functions asynchronously (concurrently)
==================================================
65.12689876556396 Using @async: istaskstarted(task01) STARTED = true
65.23786878585815 Using @async: istaskstarted(task02) STARTED = true
65.3392379283905 Using @async: istaskstarted(task03) STARTED = true
65.44055199623108 Using @async istaskstarted(task04) STARTED = true

70.44598293304443 istaskdone(task03) FINISHED = true
70.44609093666077 task03 run duration = 5.10655403137207 sec.
70.44618582725525 fetch(task03) = 175
70.44625782966614 Accumulated async run_duration = 5.421132802963257 sec.

75.45193576812744 istaskdone(task04) FINISHED = true
75.45203399658203 task04 run duration = 10.011221885681152 sec.
75.45210480690002 fetch(task04) = 200
75.45215678215027 Accumulated async run_duration = 10.427032947540283 sec.

80.4584379196167 istaskdone(task01) FINISHED = true
80.45852184295654 task01 run duration = 15.321784019470215 sec.
80.45859599113464 fetch(task01) = 600
80.45866084098816 Accumulated async run_duration = 15.433535814285278 sec.

85.46384978294373 istaskdone(task02) FINISHED = true
85.46391582489014 task02 run duration = 20.225799798965454 sec.
85.4639937877655 fetch(task02) = 1990
85.4640519618988 Accumulated async run_duration = 20.438926935195923 sec.

85.46412897109985 Total asynchronous (concurrent) run_duration = 20.439003944396973 sec.

==================================================
85.46458888053894 Alhamdulillah from WRY in Julia script. 

(base) wruslan@HPEliteBk8470p-ub1604-64b:~/Documents/julia-codes/0GOOD-JULIA# 


"""

