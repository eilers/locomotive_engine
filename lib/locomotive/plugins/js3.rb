module Locomotive
  module Plugins
    module JS3
      def js3_context
        cxt = ::V8::Context.new
        Thread.current[:site].enabled_plugin_objects_by_id.each do |plugin_id, plugin_object|
          context_storage[plugin_id].each do |k,v|
            if v.class == Variable
              cxt["#{plugin_id}_#{k}"] = v.call
            else
              cxt["#{plugin_id}_#{k}"] = v
            end
          end
        end
        cxt['mongoid_where'] = lambda{|this,criteria,key,value| criteria.where(key.to_sym => value) }
        cxt['mongoid_in'] = lambda{|this,criteria,key,value| criteria.in(key.to_sym => value) }
        cxt['mongoid_create'] = lambda{|this,criteria,object| hash = {}; object.each{|k,v| hash[k] = v}; criteria.create(hash)}
        Thread.current[:site].content_types.each do |type|
          cxt['content_'+type.slug] = type.entries
          cxt['type_'+type.slug] = eval(type.klass_name)
        end
        cxt
      end

      def add_javascript_context(plugin_id, plugin_class)
        context_storage[plugin_id] = plugin_class.javascript_context
      end

      private

      def context_storage
        @context_storage ||= {}
      end
    end

    class Variable < ::Proc
      # Tempory fix to deal with load order issue. This will be removed in the future.
    end
  end
end
