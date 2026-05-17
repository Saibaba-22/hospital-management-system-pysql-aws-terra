# gunicorn.conf.py  – production configuration
import multiprocessing

# Server socket
bind        = "0.0.0.0:5000"
backlog     = 2048

# Worker processes
workers = min((multiprocessing.cpu_count() * 2) + 1, 4)
worker_class = "sync"
worker_connections = 1000
timeout     = 30
graceful_timeout = 30
keepalive   = 2

# Logging
accesslog   = "-"       # stdout
errorlog    = "-"       # stderr
loglevel    = "info"
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'

# Graceful timeout
graceful_timeout = 30
capture_output = True

# Process naming
proc_name   = "hospital-backend"

# MEMORY LEAK PROTECTION
max_requests = 1000
max_requests_jitter = 100

# FOREGROUND MODE
daemon = False