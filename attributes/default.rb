#keep c_memcached recipe happy
default[:account][:daemon][:user] = 'henryd'
default[:account][:daemon][:group] = 'henryg'
default[:account][:default][:user] = 'hadmin'
default[:account][:default][:group] = 'henryg'

default[:memcached][:memory] = 512
default[:memcached][:port] = 11211
default[:memcached][:listen] = '0.0.0.0'
default[:memcached][:verbosity] = '-v'