std = 'luajit'
cache = true
codes = true
globals = {'_ENV'}
files['spec/'].read_globals = {
  'after_each',
  'assert',
  'before_each',
  'describe',
  'it'
}
unused_args = false
ignore = {
  '143'
}