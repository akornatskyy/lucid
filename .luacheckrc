std = 'luajit'
cache = true
codes = true
globals = {'_ENV'}
files['spec/'].read_globals = {'before_each', 'describe', 'it', 'after_each'}
unused_args = false
ignore = {}
