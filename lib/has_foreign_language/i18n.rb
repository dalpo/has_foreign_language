# HasForeignLanguage
module HasForeignLanguage

  def self.included(mod)
    mod.extend(ClassMethods)
  end

  module ClassMethods

    def has_foreign_language(*args)

      eigenclass = class << self
        self
      end

      # Define has_column? in eigenclass
      eigenclass.class_eval do
        define_method("has_column?") do |column|
          self.class.columns.map(&:name).include? column
        end
      end


      args.each do |field|
                
        # Define the marker
        eigenclass.class_eval do
          define_method("has_foreign_language_#{field.to_s}?") { true }            
        end

        # Define the getter
        define_method(field.to_s) do
          if self.class.has_column?("#{field}_#{I18n.locale}") || self.class.has_column?("#{field}_#{I18n.locale}_file_name")
            self.send("#{field}_#{I18n.locale}".to_sym)
          else
            super
          end
        end

        # Define the setter
        define_method("#{field}=") do |val|
          if self.class.has_column?("#{field}_#{I18n.locale}") || self.class.has_column?("#{field}_#{I18n.locale}_file_name")
            self["#{field}_#{I18n.locale}".to_sym] = val
          else
            self[field.to_sym] = val
          end
        end


        # Define the getter for default_locale
        define_method("#{field}_#{I18n.default_locale}") do
          self[field.to_sym]
        end

        # Define the setter for default_locale
        define_method("#{field}_#{I18n.default_locale}=") do |val|
          self[field.to_sym] = val
        end
        
      end
    end
    
  end
  
end