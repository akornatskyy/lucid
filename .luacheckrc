std = 'luajit'
cache = true
codes = true
globals = {'_ENV'}
files['spec/'].read_globals = {
  'after_each',
  'assert',
  'before_each',
  'describe',
  'insulate',
  'it',
  'setup',
  'spy',
  'stub',
  'teardown'
}
unused_args = false
ignore = {
  '143'
}
