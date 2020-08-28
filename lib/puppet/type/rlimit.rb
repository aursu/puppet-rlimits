# https://docs.puppet.com/guides/custom_types.html
Puppet::Type.newtype(:rlimit) do
  @doc = 'Manage resource limit record'
  # This property uses three methods on the provider: "create", "destroy",
  # and "exists?". The last method, somewhat obviously, is a boolean to
  # determine if the resource current exists. If a resource’s ensure property
  # is out of sync, then no other properties will be checked or modified.
  ensurable do
    defaultvalues
    defaultto :present
  end

  def self.title_patterns
    [
      [
        %r{^(.*)\/(.*)\/(.*)$},
        [
          [:domain],
          [:item],
          [:type],
        ],
      ],
      [
        %r{^(.*)\/(.*)},
        [
          [:domain],
          [:item],
        ],
      ],
    ]
  end

  newparam(:domain) do
    desc "According to man 5 limits.conf next values are possible:
- username
- @groupname
- *
- %             (maxlogins only) -> maxsyslogins
- %group        (maxlogins only)
- <min_uid>:<max_uid>
- <min_uid>:
- :<max_uid>
- @<min_gid>:<max_gid>
- @<min_gid>:
- @:<max_gid>
- %:gid"

    validate do |value|
      raise ArgumentError, "#{domain} has restricted format (see man 5 limits.conf)" unless value =~ %r{^(\*|%(\w+|:\d+)?|@?(\w+|\d+:(\d+)?|(\d+)?:\d+))}
    end
    isnamevar
  end

  newparam(:item) do
    desc "item name (see man 5 limits.conf)"

    newvalues(:core, :data, :fsize, :memlock, :nofile, :rss, :stack, :cpu,
              :nproc, :as, :maxlogins, :maxsyslogins, :priority, :locks,
              :sigpending, :msgqueue, :nice, :rtprio)
    munge do |value|
      # converting to_s in case its a boolean
      value.to_sym
    end
    isnamevar
  end

  newparam(:type) do
    desc "resource limits type (see man 5 limits.conf)"

    newvalues(:soft, :hard, :any)
    munge do |value|
      # converting to_s in case its a boolean
      value = :any if value.nil?
      value = :any if value.empty?
      value = value.to_sym if value.is_a?(String)
      value
    end
    defaultto :any
    isnamevar
  end

  # If you define a property named "owner", then when you are retrieving the
  # state of your resource, then the "owner" property will call the "owner"
  # method on the provider. In turn, when you are setting the state (because
  # the resource is out of sync), then the owner property will call the
  # "owner=" method to set the state on disk.
  newparam(:name) do
    desc 'The resource limit name'

    munge do
      "#{self[:domain]}/#{self[:item]}/#{self[:type]}"
    end
  end

  newparam(:value) do
    desc 'The resource value'

    newvalues(:unlimited, %r{^-?\d+$})
    aliasvalue(:infinity, :unlimited)

    munge do |value|
      case value
      when -1
        :unlimited
      when %r{^\d+$}, %r{^-\d+$}
        Integer(value)
      when Integer, Symbol
        value
      else
        raise ArgumentError, "Invalid value #{value.inspect}"
      end
    end
    defaultto :unlimited
  end

  validate do
    if self[:domain] =~ %r{^%}
      raise ArgumentError, 'domain which begins with % should represent only maxlogins limit' unless self[:item] == :maxlogins
    end
    if self[:item] == :nice || self[:item] == :priority
      raise ArgumentError, 'nice and priority values should have fixed range' unless self[:value] >= -19 && self[:value] < 20
    end
  end
end
