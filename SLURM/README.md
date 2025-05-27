# SLURM/HPC
## Best Practices
### Useful SBATCH
- Logging: .err and .out files
  - Use `.%a.%j` to add array ID and job ID to slurm files 

### Don't
- Submit many SLURM arrays for each small/fast jobs → inefficient  
  - Scheduler will likely have trouble managing many short-lived jobs 
  - SLURM arrays are most efficient when each process is already multithreaded and can take advantage of all cores in the node 
  - Slurm arrays should ideally only be used in scenarios where < 250 long-running elements are submitted 
  - Workloads that process hundreds/thousands of inputs that run for a few minutes/hours → should use GNU parallel instead 
  - Favor single job running on a full node: will be faster + more efficient 



## Terminology/ Vocabulary
### Architecture
**Cluster**:  collection of multiple nodes that are connected  
- Access a cluster by connecting to specific login nodes  

**Node**: individual computer consisting of 1 or more sockets  
- Login nodes (frontend node): for connecting to cluster of a facility  
  - Can be used for testing and performing interactive tasks  
- Backend nodes (compute nodes): reserved for executing computations  
  - Not accessible by users - scheduler manages access   
- Running jobs across multiple nodes: applications need MPI to not be limited by number of cores on a single node  
  - Allows for communication across nodes - Slurm does not constrain job to single node by default  

**CPU** (central processing unit): widely used in field of HPC but lacks a precise definition  
- CPU = physical chip that has 1-32 cores  

**Core**: smallest unit of computing, has one or more threads 
- Can run a single process or thread  
  - Unless core is configured to have 2 threads  

**Thread**: a way of multi-tasking - allows multiple simultaneous tasks to share the same core 
- Multiple threads ≠ multiple cores 

**Socket** (processor): physical package which contains multiple cores sharing the same memory  

### Terminology
**Task & Process**: bsoth refer to a single running program (used interchangeably)   
- Single task/process may use multiple cores (called multithreading), but won’t run across nodes  
- MPI application = multiple separate programs communicating with each other 
- Slurm task = allocation unit; process = actual program running 
- Tasks = processes run in parallel inside the user submitted job 

**Multithreading**: allows a program to use multiple cores/threads for processing

### Parallel Computing 
3 categories of parallel computing 
1. Fine grained: each process does a lot of communication with other processes. 
    - Limited by interprocess communication bandwidth 
2. Coarse grained: each process occasionally communicates with other processes 
3. **Embarrassingly parallel** (EP): processes do not communicate with each other, run completely independently 
    - Usually includes a step to merge results when last process finishes  
    - Typically SPU or I/O limited   

Many bioinformatics tasks fall into EP
- Example: read alignment - can be parallelized by breaking input sequences into subsets that are individually aligned   
- When a task is broken up to be parallelized, the subtasks can be ran in more than 1 way (MPI, threads, tasks) 
  - **MPI**: not very common in bioinformatics tools  
    - Difficult to debug  
    - Overkill for breaking up EP tasks 
    - Some Compute Clusters by default rejects jobs that request more than 1 node 
    - MPI is rare in bioinformatics 
  - **Threads**: most bioinformatics tools that has parallel option use threading 
    - Applications that take argument specifying cores, threads, or CPUs = likely to use this model to parallelize their work 
    - Threads = more akin to the concept of cores rather than tasks

### Submission Parameters 
**-n (—ntasks)**: 
- Useful to run commands in parallel within the same batch script 
- Example: request 2 tasks and run read mapping command on 2 samples in parallel (similar to submitting arrays but processes are paralleled within the same script)
- Useful StackOverflow answer: [link](https://stackoverflow.com/questions/39186698/what-does-the-ntasks-or-n-tasks-does-in-slurm)

**-c (--cpus-per-task)**: number of CPUs allocated per task (number of cores to allocate)   
- This is usually the `--threads` param in bioinformatics software  

**–ntasks vs –cpus-per-task** 
- Both allocates cores (-n=1 and -c=1 allocates 1 core to job) 
  - `--ntasks=24` → allocates a job with 24 tasks, each task takes up 1 core/CPU, _may be split across multiple nodes_  
  - `--cpus-per-task=24` → allocates a job with 1 task, 24 CPUs for that task - total of 24 CPUs _on a single node_  
- If the number of CPUs requested in `–cpus-per-task` is greater than number of CPUs a compute node has: the _job will fail_  as `-c` tries to allocate cores within the same node.  

### Available Resource Check 
**Job efficiency** (for jobs that completed): `seff [jobid]`  

**Node Configuration**: 
- List of partitions you have access to: `sinfo`
- List of nodes in a partition: `sinfo -p [partition_name]`  
- Information about a node in the partition: `scontrol show node node_name`
  - CPUTot: how many CPUs
  - RealMemory: mem available
  - ThreadsPerCore: how many thread per CPU

**Available cores in the partition**
- `sinfo -p [partition_name] -o "%n %e %m %a %c %C"`
  - Output: A=allocated, I=idle, O=other, T=total

**Previous Jobs from a User**
- `sacct -u [username]`
- `sacct -u [username] --delimiter "," -S 2023-11-29 -E 2023-11-30`
  - To see jobs from start (-S) to end (-E) 
  - Then use seff to see how efficient a job requested was 
- `sacct -u nvo -S now-3days -E now | grep -v -e 'COMPLETED' -e 'RUNNING'`  
  - grep: obtain jobs that failed/canceled/etc.  



### Useful Commands
- Submit Python script to queue without an .sbatch script: 
  - `sbatch --partition=sched_mit_chisholm --ntasks=1 --cpus-per-task=1 --mem=10G --time=1-0 --wrap="python3 script_name.py" --job-name=job_name`  
- Changing array throttling limit - while job is running 
  - `scontrol update ArrayTaskThrottle=[total_job] JobId=[job_ID]`
- Batch cancelling jobs:
  - Cancel jobs with shared name: 
    - `squeue -u [username] | grep 'job_name' | awk '{print $1}' | xargs scancel`
  - If jobs start with "9916"
    - `squeue -u [username] | grep '9916' | awk '{print $1}' | xargs scancel`
