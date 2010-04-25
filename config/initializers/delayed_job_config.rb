Delayed::Job.destroy_failed_jobs = false
Delayed::Job.max_attempts = 3
Delayed::Job.max_run_time = 5.minutes
