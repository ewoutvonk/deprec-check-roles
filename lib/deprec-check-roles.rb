# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

# prevent loading when called by Bundler, only load when called by capistrano
if caller.any? { |callstack_line| callstack_line =~ /^Capfile:/ }
  unless Capistrano::Configuration.respond_to?(:instance)
    abort "deprec-check-roles requires Capistrano 2"
  end

  def define_check_roles_tasks(base_namespace)
    Capistrano::Configuration.instance.send(base_namespace).namespaces.keys.each do |ns_name|
      ns = Capistrano::Configuration.instance.send(base_namespace).send(ns_name)
      unless ns.respond_to?(:check_roles)
        Capistrano::Configuration.instance.namespace base_namespace do
          namespace ns_name do
            desc "check if all roles are defined for :#{ns_name}"
            task :check_roles do
              user_defined_roles = roles.keys
              recipe_declared_roles = ns.tasks.collect { |k,v| v.options.has_key?(:roles) ? v.options[:roles] : nil }.compact.flatten.uniq
          
              missing_roles = recipe_declared_roles - user_defined_roles
          
              abort "You should define role(s): #{missing_roles.join(', ')}\nPlease run this task again after adding them to check further." unless missing_roles.empty?
            end
          end
        end
      end
    end
  end

  define_check_roles_tasks(:deprec)
end