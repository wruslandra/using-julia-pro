# File: julia-execute-functions-async.jl
# Date:     Sun Jul 14 09:05:43 +08 2019 for julia ver 1.1.1
# Modified: Fri Aug 23 21:10:21 +08 2019 for julia ver 1.2.0
# Author  : WRY
# =========================================================
"""

This julia code compares the synchronous and asynchronous execution times (run_durations) of a common shared function named "do_same_work(parameters)". There are four(4) tasks to be executed. Each task will perform the same function, do_same_work(parameters). However, each task will be provided with different input parameters. In this code, we decided on four(4) tasks because we have physically 4-CPU cores on our notebook.  

In Julia, the declaration of tasks using macros @async and @sync on a function launches (executes) the task immediately. We can think of these macros as task launchers instead of just function definitions.. 

Example synchronous tasks:
	task01 = @sync do_same_work("task01", 100, 10, 0.3, 5);
   	task02 = @sync do_same_work("task02", 10, 10, 0.1, 10);
 	task03 = @sync do_same_work("task03", 50, 5, 0.2, 4); 
 	task04 = @sync do_same_work("task04", 0, 10, 0.5, 7);

Example asynchronous tasks:
	task11 = @async do_same_work("task11", 100, 10, 0.3, 5);
   	task12 = @async do_same_work("task12", 10, 10, 0.1, 10);
 	task13 = @async do_same_work("task13", 50, 5, 0.2, 4); 
 	task14 = @async do_same_work("task14", 0, 10, 0.5, 7);

RESULTS EXTRACTED:

Total synchronous  (sequential) run_duration = 26.24190902709961 sec.
Total asynchronous (concurrent) run_duration = 10.42530083656311 sec.

(1) In the synchronous (sequential) execution, all four(4) tasks  will be executed sequentially (one after another) and the accumulated total time will be the synchronous run_duration. In this mode, the running sequence is (task01 -> task02 -> task03 -> task04) and finish. The individual task durations are additive. From the results above, the total run_duration to finish is about 26 seconds. 

(2) Asynchronous running tasks means independent running tasks, that is, once started the each task run to completion without interruption from any other event. In this asynchronous (concurrent) execution, all four(4) tasks  will be executed simultaneously (task11, task12, task13 and task14). In this mode, all four(4) tasks execute in overlapping time, with one task on each CPU core. Since the tasks are running in parallel, the net completion time taken is the time to finish the longest task. The times are overlapping and so are not additive, meaning the earlier tasks have already finished. From the results above, the longest task took about 10 seconds. 

(3) For demonstration purposes, we uncommented a print statement to show details of task executions in overlapping time. The normal run is not to display this line. From our results provided at the end of this code, we get overllapping runs:

	Time range (41.41 - 45.65) sec. All tasks task11, task12, task13 and task14 are running in parallel. 
	Time range (45.65 - 46.53) sec. Task13 finished. Tasks task11, task12 and task14 continue running in parallel. 
	Time range (46.53 - 48.74) sec. Task11 finished, Tasks task12 and task14 continue running in parallel.
	Time range (48.74 - 51.56) sec. Task14 finished. Task12 continue running to completion. 
 
SOME NOTES.

(N1) Putting macro @async and @sync (on function) immediately and automatically start both task executions.

(N2) Because we display high resolution time in the outputs, we display the start and finish times for all of the four(4) tasks, covering both synchronous and asynchronous execution. 

(N3) We also can sort the results display according to this time. 

(N4) To prove that the calculations are correct, all tasks running in synchronous and asynchronous modes gave the same answers. 

(N5) In the asynchronous case, we can print the time details of the individual tasks (taskname) as they happen, so we can see the overlapping task executions.   

"""

# =========================================================
using Dates 
start_time = Dates.time();

println("=================================================="); 
print(Dates.time()-start_time, "	 Current date today() = ", Dates.today(), "\n")
print(Dates.time()-start_time, "	 Current date time now: ", Dates.now(), "\n")
print(Dates.time()-start_time, "	 Current running program script: ", PROGRAM_FILE, "\n")
print(Dates.time()-start_time, "	 Bismillah from WRY in Julia script. \n") 
println("==================================================");

using InteractiveUtils
import InteractiveUtils
## @show (versioninfo());
@show (InteractiveUtils.versioninfo());

println("==================================================");
using PyCall
psutil = pyimport("psutil")
numCPU = psutil.cpu_count()
print(Dates.time()-start_time, "	 PyCall: Value of psutil.cpu_count() = $numCPU \n")

using Hwloc
topology = Hwloc.topology_load()
counts = Hwloc.histmap(topology)
ncores = counts[:Core]
npus = counts[:PU]
print(Dates.time()-start_time, "	 Hwloc: This machine has $ncores cores and $npus PUs (processing units). \n")
num_physicalcores = Hwloc.num_physical_cores()
print(Dates.time()-start_time, "	 Hwloc: This machine has $num_physicalcores physical cores. \n")

# View number of workers + master process
# Create n workers during a session if required
# workers are addressed by numbers (PIDs)
# master process had PID =1, the rest are PID of workers
using Distributed
Distributed.addprocs(4);
my_nprocs = Distributed.nprocs();
print(Dates.time()-start_time, "	 Number of workers + master process = $my_nprocs \n")
my_wpid = Distributed.workers();
print(Dates.time()-start_time, "	 List of workers PIDs = $my_wpid \n")
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
 	println(Dates.time()-start_time, "	 Task $taskname execution starting ...");

    # Perform while loop within run_time_duration seconds
    while (time() - start_fxn_time) < run_time_duration  
        result += delta
        sleep(time_sleep)

    ## UNCOMMENT LINE BELOW FOR FULL DETAILS OF CONCURRENT TASK RUNS
	## println(Dates.time()-start_time, "\t $taskname interim result = ", result);  
    end 

    println(Dates.time()-start_time, "	 Task $taskname finished. Result = ", result);
    return (result) 
end; 

# =========================================================
function run_functions_sequential()
# =========================================================
start_time_sync = Dates.time();

	task01 = @sync do_same_work("task01", 100, 10, 0.3, 5);
   	task02 = @sync do_same_work("task02", 10, 10, 0.1, 10);
 	task03 = @sync do_same_work("task03", 50, 5, 0.2, 4); 
 	task04 = @sync do_same_work("task04", 0, 10, 0.5, 7);

	println(Dates.time()-start_time, "	 Return value of task01 = ", fetch(task01));
	println(Dates.time()-start_time, "	 Return value of task02 = ", fetch(task02));
	println(Dates.time()-start_time, "	 Return value of task03 = ", fetch(task03));
	println(Dates.time()-start_time, "	 Return value of task04 = ", fetch(task04));

	println();
    println(Dates.time()-start_time, "	 Total synchronous (sequential) run_duration = ", (time() - start_time_sync), " sec.");

 	println();
end;

# =========================================================
function run_functions_async()
# =========================================================
   start_async_time = time()

   # NOTE: Putting macro @async (on function) immediately starts task execution

   task11 = @async do_same_work("task11", 100, 10, 0.3, 5); sleep(0.1); 
   println(Dates.time()-start_time, "	 Using @async: istaskstarted(task11) STARTED = ", istaskstarted(task11)); 
   time_start_task11 = time();

   task12 = @async do_same_work("task12", 10, 10, 0.1, 10); sleep(0.1);  
   println(Dates.time()-start_time, "	 Using @async: istaskstarted(task12) STARTED = ", istaskstarted(task12)); 
   time_start_task12 = time();

   task13 = @async do_same_work("task13", 50, 5, 0.2, 4);  sleep(0.1); 
   println(Dates.time()-start_time, "	 Using @async: istaskstarted(task13) STARTED = ", istaskstarted(task13)); 
   time_start_task13 = time();

   task14 = @async do_same_work("task14", 0, 10, 0.5, 7); sleep(0.1); 
   println(Dates.time()-start_time, "	 Using @async: istaskstarted(task14) STARTED = ", istaskstarted(task14)); 
   time_start_task14 = time();

   count_finish_task11 = 0
   count_finish_task12 = 0
   count_finish_task13 = 0
   count_finish_task14 = 0

   while (!istaskdone(task11) || !istaskdone(task12) || !istaskdone(task13) || !istaskdone(task14))
	sleep(1)  ## MUST HAVE sleep TO DISPLAY

	# ==============
        if (istaskdone(task11) == true)
            time_finish_task11 = time();

		    count_finish_task11 += 1;
	    end
		if (istaskdone(task11) == true) && (count_finish_task11 == 1)  # TO PRINT ONCE ONLY
			println()
			println(Dates.time()-start_time, "	 istaskdone(task11) FINISHED = ", istaskdone(task11)); 	
			println(Dates.time()-start_time, "	 task11 run duration = ", (time_finish_task11 - time_start_task11), " sec."); 
			println(Dates.time()-start_time, "	 fetch(task11) = ", fetch(task11)); 
			println(Dates.time()-start_time, "	 Accumulated async run_duration = ", (time() - start_async_time), " sec.");
		end

	# ==============
        if (istaskdone(task12) == true)
			time_finish_task12 = time();
			count_finish_task12 += 1;
		end
		if (istaskdone(task12) == true) && (count_finish_task12 == 1)
			println()
			println(Dates.time()-start_time, "	 istaskdone(task12) FINISHED = ", istaskdone(task12)); 	
			println(Dates.time()-start_time, "	 task12 run duration = ", (time_finish_task12 - time_start_task12), " sec."); 
			println(Dates.time()-start_time, "	 fetch(task12) = ", fetch(task12)); 
			println(Dates.time()-start_time, "	 Accumulated async run_duration = ", (time() - start_async_time), " sec.");
		end
	
    # ==============
        if (istaskdone(task13) == true)
			time_finish_task13 = time();
			count_finish_task13 += 1
		end
		if (istaskdone(task13) == true) && (count_finish_task13 == 1)
			println()
			println(Dates.time()-start_time, "	 istaskdone(task13) FINISHED = ", istaskdone(task13)); 	
			println(Dates.time()-start_time, "	 task13 run duration = ", (time_finish_task13 - time_start_task13), " sec.");  
			println(Dates.time()-start_time, "	 fetch(task13) = ", fetch(task13)); 
			println(Dates.time()-start_time, "	 Accumulated async run_duration = ", (time() - start_async_time), " sec."); 
        end

	# ==============
        if (istaskdone(task14) == true)
			time_finish_task14 = time();
			count_finish_task14 += 1
		end
		if (istaskdone(task14) == true) && (count_finish_task14 == 1)
        	println()
			println(Dates.time()-start_time, "	 istaskdone(task14) FINISHED = ", istaskdone(task14)); 	
			println(Dates.time()-start_time, "	 task14 run duration = ", (time_finish_task14 - time_start_task14), " sec."); 
			println(Dates.time()-start_time, "	 fetch(task14) = ", fetch(task14)); 
			println(Dates.time()-start_time, "	 Accumulated async run_duration = ", (time() - start_async_time), " sec.");  
        end

	# ==============
    end # end..while   
        
    println();
    println(Dates.time()-start_time, "	 Total asynchronous (concurrent) run_duration = ", (time() - start_async_time), " sec.");
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
print(Dates.time()-start_time, "	 Alhamdulillah from WRY in Julia script. \n\n") 
# =========================================================


"""
===========================================================
EXECUTION NO. 1 RESULTS (SUMMARY)
===========================================================

(base) wruslan@HPEliteBk8470p-ub1604-64b:~/Documents/julia-codes/julia-async# julia julia-execute-functions-sync-and-async.jl 
==================================================
0.0038509368896484375	 Current date today() = 2019-08-25
0.11660194396972656	 Current date time now: 2019-08-25T00:36:20.15
0.20825409889221191	 Current running program script: julia-execute-functions-sync-and-async.jl
0.21663999557495117	 Bismillah from WRY in Julia script. 
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
InteractiveUtils.versioninfo() = nothing
==================================================
5.643465042114258	 PyCall: Value of psutil.cpu_count() = 4 
8.736314058303833	 Hwloc: This machine has 2 cores and 4 PUs (processing units). 
8.745645999908447	 Hwloc: This machine has 2 physical cores. 
14.64233398437500	 Number of workers + master process = 5 
14.647485971450806	 List of workers PIDs = [2, 3, 4, 5] 
==================================================
 Run functions synchronously (sequentially)
==================================================
14.854571104049683	 Task task01 execution starting ...
20.016348123550415	 Task task01 finished. Result = 270
20.032320976257324	 Task task02 execution starting ...
30.04478096961975	 Task task02 finished. Result = 1000
30.044909954071045	 Task task03 execution starting ...
34.07003712654114	 Task task03 finished. Result = 150
34.07016706466675	 Task task04 execution starting ...
41.092036962509155	 Task task04 finished. Result = 140
41.09217309951782	 Return value of task01 = 270
41.092227935791016	 Return value of task02 = 1000
41.092276096343994	 Return value of task03 = 150
41.09233093261719	 Return value of task04 = 140

41.096473932266235	 Total synchronous (sequential) run_duration = 26.24190902709961 sec.

==================================================
 Run functions asynchronously (concurrently)
==================================================
41.21833109855652	 Task task11 execution starting ...
41.31264090538025	 Using @async: istaskstarted(task11) STARTED = true
41.32846212387085	 Task task12 execution starting ...
41.4227409362793	 Using @async: istaskstarted(task12) STARTED = true
41.428739070892334	 Task task13 execution starting ...
41.524219036102295	 Using @async: istaskstarted(task13) STARTED = true
41.53031802177429	 Task task14 execution starting ...
41.624711990356445	 Using @async: istaskstarted(task14) STARTED = true

45.4528489112854	 Task task13 finished. Result = 150
45.62947106361389	 istaskdone(task13) FINISHED = true
45.6295690536499	 task13 run duration = 4.105076789855957 sec.
45.62962794303894	 fetch(task13) = 150
45.62967491149902	 Accumulated async run_duration = 4.417437791824341 sec.

46.33898901939392	 Task task11 finished. Result = 270
46.63076901435852	 istaskdone(task11) FINISHED = true
46.63087201118469	 task11 run duration = 5.30831503868103 sec.
46.63095498085022	 fetch(task11) = 270
46.63101100921631	 Accumulated async run_duration = 5.418774843215942 sec.

48.544963121414185	 Task task14 finished. Result = 140
48.63340997695923	 istaskdone(task14) FINISHED = true
48.6334969997406	 task14 run duration = 7.008519887924194 sec.
48.63355994224548	 fetch(task14) = 140
48.63361096382141	 Accumulated async run_duration = 7.421374797821045 sec.

51.33668494224548	 Task task12 finished. Result = 1000
51.63721799850464	 istaskdone(task12) FINISHED = true
51.637300968170166	 task12 run duration = 10.214318990707397 sec.
51.63738799095154	 fetch(task12) = 1000
51.63744902610779	 Accumulated async run_duration = 10.425212860107422 sec.

51.63753795623779	 Total asynchronous (concurrent) run_duration = 10.42530083656311 sec.

==================================================
51.63802194595337	 Alhamdulillah from WRY in Julia script. 

(base) wruslan@HPEliteBk8470p-ub1604-64b:~/Documents/julia-codes/julia-async#

===========================================================
EXECUTION NO. 2 RESULTS (DETAILS)
===========================================================

(base) wruslan@HPEliteBk8470p-ub1604-64b:~/Documents/julia-codes/julia-async# julia julia-execute-functions-sync-and-async.jl 
==================================================
0.005164146423339844	 Current date today() = 2019-08-25
0.1321861743927002	 Current date time now: 2019-08-25T01:23:15.035
0.22469496726989746	 Current running program script: julia-execute-functions-sync-and-async.jl
0.23349404335021973	 Bismillah from WRY in Julia script. 
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
InteractiveUtils.versioninfo() = nothing
==================================================
5.691396951675415	 PyCall: Value of psutil.cpu_count() = 4 
8.834265947341919	 Hwloc: This machine has 2 cores and 4 PUs (processing units). 
8.84364914894104	 Hwloc: This machine has 2 physical cores. 
14.81456208229065	 Number of workers + master process = 5 
14.81971001625061	 List of workers PIDs = [2, 3, 4, 5] 
==================================================
 Run functions synchronously (sequentially)
==================================================
15.034242153167725	 Task task01 execution starting ...
15.374465942382812	 task01 interim result = 110
15.69155216217041	 task01 interim result = 120
15.993047952651978	 task01 interim result = 130
16.29454517364502	 task01 interim result = 140
16.59604811668396	 task01 interim result = 150
16.8975350856781	 task01 interim result = 160
17.199035167694092	 task01 interim result = 170
17.500508069992065	 task01 interim result = 180
17.801987171173096	 task01 interim result = 190
18.103463172912598	 task01 interim result = 200
18.40495800971985	 task01 interim result = 210
18.706432104110718	 task01 interim result = 220
19.007914066314697	 task01 interim result = 230
19.309412002563477	 task01 interim result = 240
19.610882997512817	 task01 interim result = 250
19.912353038787842	 task01 interim result = 260
20.21384906768799	 task01 interim result = 270
20.213962078094482	 Task task01 finished. Result = 270
20.214020013809204	 Task task02 execution starting ...
20.315248012542725	 task02 interim result = 20
20.416531085968018	 task02 interim result = 30
20.51780915260315	 task02 interim result = 40
20.61909794807434	 task02 interim result = 50
20.720378160476685	 task02 interim result = 60
20.821660041809082	 task02 interim result = 70
20.922935962677002	 task02 interim result = 80
21.024233102798462	 task02 interim result = 90
21.125511169433594	 task02 interim result = 100
21.226786136627197	 task02 interim result = 110
21.328066110610962	 task02 interim result = 120
21.429391145706177	 task02 interim result = 130
21.53065800666809	 task02 interim result = 140
21.631932973861694	 task02 interim result = 150
21.733211994171143	 task02 interim result = 160
21.834479093551636	 task02 interim result = 170
21.935755014419556	 task02 interim result = 180
22.037089109420776	 task02 interim result = 190
22.138367176055908	 task02 interim result = 200
22.239657163619995	 task02 interim result = 210
22.340944051742554	 task02 interim result = 220
22.442212104797363	 task02 interim result = 230
22.543493032455444	 task02 interim result = 240
22.644776105880737	 task02 interim result = 250
22.74605417251587	 task02 interim result = 260
22.847325086593628	 task02 interim result = 270
22.94861602783203	 task02 interim result = 280
23.049893140792847	 task02 interim result = 290
23.151169061660767	 task02 interim result = 300
23.252444982528687	 task02 interim result = 310
23.353716135025024	 task02 interim result = 320
23.454988956451416	 task02 interim result = 330
23.556262969970703	 task02 interim result = 340
23.657539129257202	 task02 interim result = 350
23.758814096450806	 task02 interim result = 360
23.86008906364441	 task02 interim result = 370
23.961400032043457	 task02 interim result = 380
24.06267809867859	 task02 interim result = 390
24.16395401954651	 task02 interim result = 400
24.26525115966797	 task02 interim result = 410
24.366565942764282	 task02 interim result = 420
24.467859983444214	 task02 interim result = 430
24.569159984588623	 task02 interim result = 440
24.670461177825928	 task02 interim result = 450
24.77176308631897	 task02 interim result = 460
24.87306308746338	 task02 interim result = 470
24.974363088607788	 task02 interim result = 480
25.075658082962036	 task02 interim result = 490
25.176931142807007	 task02 interim result = 500
25.278205156326294	 task02 interim result = 510
25.379480123519897	 task02 interim result = 520
25.480751991271973	 task02 interim result = 530
25.582029104232788	 task02 interim result = 540
25.68331217765808	 task02 interim result = 550
25.784582138061523	 task02 interim result = 560
25.885858058929443	 task02 interim result = 570
25.987131118774414	 task02 interim result = 580
26.08840799331665	 task02 interim result = 590
26.189690113067627	 task02 interim result = 600
26.290969133377075	 task02 interim result = 610
26.392251014709473	 task02 interim result = 620
26.49354314804077	 task02 interim result = 630
26.594818115234375	 task02 interim result = 640
26.6961030960083	 task02 interim result = 650
26.79741597175598	 task02 interim result = 660
26.898673057556152	 task02 interim result = 670
26.99996304512024	 task02 interim result = 680
27.10123896598816	 task02 interim result = 690
27.20253300666809	 task02 interim result = 700
27.30380606651306	 task02 interim result = 710
27.405107975006104	 task02 interim result = 720
27.506405115127563	 task02 interim result = 730
27.607702016830444	 task02 interim result = 740
27.70900297164917	 task02 interim result = 750
27.810301065444946	 task02 interim result = 760
27.91160011291504	 task02 interim result = 770
28.012899160385132	 task02 interim result = 780
28.114197969436646	 task02 interim result = 790
28.215495109558105	 task02 interim result = 800
28.316792964935303	 task02 interim result = 810
28.418097019195557	 task02 interim result = 820
28.519397974014282	 task02 interim result = 830
28.62069797515869	 task02 interim result = 840
28.721996068954468	 task02 interim result = 850
28.82329297065735	 task02 interim result = 860
28.924592971801758	 task02 interim result = 870
29.025891065597534	 task02 interim result = 880
29.127192974090576	 task02 interim result = 890
29.22849202156067	 task02 interim result = 900
29.32978916168213	 task02 interim result = 910
29.431087017059326	 task02 interim result = 920
29.532389163970947	 task02 interim result = 930
29.633697032928467	 task02 interim result = 940
29.734982013702393	 task02 interim result = 950
29.83628511428833	 task02 interim result = 960
29.93757915496826	 task02 interim result = 970
30.03887701034546	 task02 interim result = 980
30.140154123306274	 task02 interim result = 990
30.241429090499878	 task02 interim result = 1000
30.24152898788452	 Task task02 finished. Result = 1000
30.24156403541565	 Task task03 execution starting ...
30.442873001098633	 task03 interim result = 55
30.644243001937866	 task03 interim result = 60
30.845622062683105	 task03 interim result = 65
31.047017097473145	 task03 interim result = 70
31.248425006866455	 task03 interim result = 75
31.44980216026306	 task03 interim result = 80
31.651177167892456	 task03 interim result = 85
31.852550983428955	 task03 interim result = 90
32.053946018218994	 task03 interim result = 95
32.25534009933472	 task03 interim result = 100
32.4567129611969	 task03 interim result = 105
32.658092975616455	 task03 interim result = 110
32.85946297645569	 task03 interim result = 115
33.06085801124573	 task03 interim result = 120
33.26223611831665	 task03 interim result = 125
33.4626100063324	 task03 interim result = 130
33.663984060287476	 task03 interim result = 135
33.86538600921631	 task03 interim result = 140
34.06676411628723	 task03 interim result = 145
34.26816201210022	 task03 interim result = 150
34.268259048461914	 Task task03 finished. Result = 150
34.26830697059631	 Task task04 execution starting ...
34.769936084747314	 task04 interim result = 10
35.271618127822876	 task04 interim result = 20
35.77331495285034	 task04 interim result = 30
36.274994134902954	 task04 interim result = 40
36.776684045791626	 task04 interim result = 50
37.27835416793823	 task04 interim result = 60
37.78004598617554	 task04 interim result = 70
38.281721115112305	 task04 interim result = 80
38.78340411186218	 task04 interim result = 90
39.28508114814758	 task04 interim result = 100
39.78677201271057	 task04 interim result = 110
40.28845000267029	 task04 interim result = 120
40.79013013839722	 task04 interim result = 130
41.2918119430542	 task04 interim result = 140
41.29192495346069	 Task task04 finished. Result = 140
41.29197812080383	 Return value of task01 = 270
41.29201316833496	 Return value of task02 = 1000
41.29204797744751	 Return value of task03 = 150
41.29208302497864	 Return value of task04 = 140

41.296000957489014	 Total synchronous (sequential) run_duration = 26.261765956878662 sec.

==================================================
 Run functions asynchronously (concurrently)
==================================================
41.418923139572144	 Task task11 execution starting ...
41.51421594619751	 Using @async: istaskstarted(task11) STARTED = true
41.53051805496216	 Task task12 execution starting ...
41.62478494644165	 Using @async: istaskstarted(task12) STARTED = true
41.63113713264465	 Task task13 execution starting ...
41.632328033447266	 task12 interim result = 20
41.7195839881897	 task11 interim result = 110
41.72575807571411	 Using @async: istaskstarted(task13) STARTED = true
41.73286294937134	 Task task14 execution starting ...
41.73407506942749	 task12 interim result = 30
41.82734799385071	 Using @async: istaskstarted(task14) STARTED = true
41.83155012130737	 task13 interim result = 55
41.83473610877991	 task12 interim result = 40
41.935999155044556	 task12 interim result = 50
42.02130317687988	 task11 interim result = 120
42.03249216079712	 task13 interim result = 60
42.03666615486145	 task12 interim result = 60
42.13792395591736	 task12 interim result = 70
42.23421597480774	 task14 interim result = 10
42.23426699638367	 task13 interim result = 65
42.23843812942505	 task12 interim result = 80
42.322689056396484	 task11 interim result = 130
42.339921951293945	 task12 interim result = 90
42.43619894981384	 task13 interim result = 70
42.441394090652466	 task12 interim result = 100
42.54266715049744	 task12 interim result = 110
42.62393903732300	 task11 interim result = 140
42.637163162231445	 task13 interim result = 75
42.64434099197388	 task12 interim result = 120
42.73460602760315	 task14 interim result = 20
42.74580407142639	 task12 interim result = 130
42.838139057159424	 task13 interim result = 80
42.84734010696411	 task12 interim result = 140
42.924575090408325	 task11 interim result = 150
42.94879698753357	 task12 interim result = 150
43.03904700279236	 task13 interim result = 85
43.05023503303528	 task12 interim result = 160
43.1514790058136	 task12 interim result = 170
43.225744009017944	 task11 interim result = 160
43.235954999923706	 task14 interim result = 30
43.240148067474365	 task13 interim result = 90
43.25342297554016	 task12 interim result = 180
43.35470008850098	 task12 interim result = 190
43.4409761428833	 task13 interim result = 95
43.45624899864197	 task12 interim result = 200
43.52648997306824	 task11 interim result = 170
43.55775499343872	 task12 interim result = 210
43.64200711250305	 task13 interim result = 100
43.659234046936035	 task12 interim result = 220
43.736494064331055	 task14 interim result = 40
43.76072406768799	 task12 interim result = 230
43.82798409461975	 task11 interim result = 180
43.8432731628418	 task13 interim result = 105
43.86150598526001	 task12 interim result = 240
43.96280908584595	 task12 interim result = 250
44.04508996009827	 task13 interim result = 110
44.064388036727905	 task12 interim result = 260
44.12864112854004	 task11 interim result = 190
44.165929079055786	 task12 interim result = 270
44.23819899559021	 task14 interim result = 50
44.2464120388031	 task13 interim result = 115
44.26666712760925	 task12 interim result = 280
44.367969036102295	 task12 interim result = 290
44.43025207519531	 task11 interim result = 200
44.447479009628296	 task13 interim result = 120
44.46874809265137	 task12 interim result = 300
44.57002305984497	 task12 interim result = 310
44.64930510520935	 task13 interim result = 125
44.67055416107178	 task12 interim result = 320
44.7318000793457	 task11 interim result = 210
44.73900604248047	 task14 interim result = 60
44.77227997779846	 task12 interim result = 330
44.850672006607056	 task13 interim result = 130
44.873897075653076	 task12 interim result = 340
44.97519016265869	 task12 interim result = 350
45.03344511985779	 task11 interim result = 220
45.05164694786072	 task13 interim result = 135
45.07589912414551	 task12 interim result = 360
45.177178144454956	 task12 interim result = 370
45.24044108390808	 task14 interim result = 70
45.25264501571655	 task13 interim result = 140
45.277913093566895	 task12 interim result = 380
45.33515405654907	 task11 interim result = 230
45.37939500808716	 task12 interim result = 390
45.45369911193848	 task13 interim result = 145
45.48096799850464	 task12 interim result = 400
45.58226799964905	 task12 interim result = 410
45.63552904129028	 task11 interim result = 240
45.6548011302948	 task13 interim result = 150
45.65490102767944	 Task task13 finished. Result = 150
45.68418216705322	 task12 interim result = 420
45.74150109291077	 task14 interim result = 80
45.78575897216797	 task12 interim result = 430

45.832019090652466	 istaskdone(task13) FINISHED = true
45.832087993621826	 task13 run duration = 4.106119871139526 sec.
45.83217906951904	 fetch(task13) = 150
45.832237005233765	 Accumulated async run_duration = 4.419543981552124 sec.
45.887449979782104	 task12 interim result = 440
45.93672204017639	 task11 interim result = 250
45.98898696899414	 task12 interim result = 450
46.09025502204895	 task12 interim result = 460
46.19155716896057	 task12 interim result = 470
46.23780608177185	 task11 interim result = 260
46.24298715591431	 task14 interim result = 90
46.29321599006653	 task12 interim result = 480
46.39448809623718	 task12 interim result = 490
46.495790004730225	 task12 interim result = 500
46.53904104232788	 task11 interim result = 270
46.539133071899414	 Task task11 finished. Result = 270
46.59733295440674	 task12 interim result = 510
46.69862699508667	 task12 interim result = 520
46.74388313293457	 task14 interim result = 100
46.800132036209106	 task12 interim result = 530

46.83343696594238	 istaskdone(task11) FINISHED = true
46.83350896835327	 task11 run duration = 5.309460878372192 sec.
46.833598136901855	 fetch(task11) = 270
46.83366298675537	 Accumulated async run_duration = 5.42097020149231 sec.
46.90088701248169	 task12 interim result = 540
47.00219511985779	 task12 interim result = 550
47.103496074676514	 task12 interim result = 560
47.20480704307556	 task12 interim result = 570
47.24510312080383	 task14 interim result = 110
47.30637812614441	 task12 interim result = 580
47.40766716003418	 task12 interim result = 590
47.50897407531738	 task12 interim result = 600
47.61027908325195	 task12 interim result = 610
47.71158504486084	 task12 interim result = 620
47.745845079422	 	 task14 interim result = 120
47.81309914588928	 task12 interim result = 630
47.91446399688721	 task12 interim result = 640
48.0157470703125	 task12 interim result = 650
48.117040157318115	 task12 interim result = 660
48.21835207939148	 task12 interim result = 670
48.24655604362488	 task14 interim result = 130
48.319831132888794	 task12 interim result = 680
48.42110800743103	 task12 interim result = 690
48.522387981414795	 task12 interim result = 700
48.62367510795593	 task12 interim result = 710
48.72496008872986	 task12 interim result = 720
48.74817705154419	 task14 interim result = 140
48.74826908111572	 Task task14 finished. Result = 140
48.82648205757141	 task12 interim result = 730

48.83568000793457	 istaskdone(task14) FINISHED = true
48.83574914932251	 task14 run duration = 7.008193016052246 sec.
48.835801124572754	 fetch(task14) = 140
48.83583617210388	 Accumulated async run_duration = 7.423143148422241 sec.
48.92805314064026	 task12 interim result = 740
49.0293869972229	 task12 interim result = 750
49.13069415092468	 task12 interim result = 760
49.232001066207886	 task12 interim result = 770
49.33328914642334	 task12 interim result = 780
49.43461203575134	 task12 interim result = 790
49.53592896461487	 task12 interim result = 800
49.637197971343994	 task12 interim result = 810
49.73850202560425	 task12 interim result = 820
49.83989715576172	 task12 interim result = 830
49.94120502471924	 task12 interim result = 840
50.042508125305176	 task12 interim result = 850
50.1438090801239	 task12 interim result = 860
50.24510312080383	 task12 interim result = 870
50.34640717506409	 task12 interim result = 880
50.44770407676697	 task12 interim result = 890
50.54900407791138	 task12 interim result = 900
50.650304079055786	 task12 interim result = 910
50.751599073410034	 task12 interim result = 920
50.8529839515686	 task12 interim result = 930
50.954272985458374	 task12 interim result = 940
51.05555295944214	 task12 interim result = 950
51.1568341255188	 task12 interim result = 960
51.25811815261841	 task12 interim result = 970
51.35939812660217	 task12 interim result = 980
51.46069097518921	 task12 interim result = 990
51.56194710731506	 task12 interim result = 1000
51.56204915046692	 Task task12 finished. Result = 1000

51.83947515487671	 istaskdone(task12) FINISHED = true
51.839540004730225	 task12 run duration = 10.21456789970398 sec.
51.83962917327881	 fetch(task12) = 1000
51.83967709541321	 Accumulated async run_duration = 10.426984071731567 sec.

51.83975911140442	 Total asynchronous (concurrent) run_duration = 10.427066087722778 sec.

==================================================
51.84021496772766	 Alhamdulillah from WRY in Julia script. 

(base) wruslan@HPEliteBk8470p-ub1604-64b:~/Documents/julia-codes/julia-async# 


"""

