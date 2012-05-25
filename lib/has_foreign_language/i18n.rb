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
          self.columns.map(&:name).include? column.to_s
        end
      end


      args.each do |field|
                
        # Define the marker
        eigenclass.class_eval do
          define_method("has_foreign_language_#{field.to_s}?") { true }            
        end

        # Define the getter
        define_method(field.to_s) do

          if self.class.has_column?("#{field}_#{I18n.locale}")
            self["#{field}_#{I18n.locale}".to_sym]  
          elsif self.class.has_column?("#{field}_#{I18n.locale}_file_name")
            self.attachment_for "#{field}_#{I18n.locale}".to_sym
          elsif self.class.has_column?("#{field}_file_name")
            self.attachment_for "#{field}".to_sym
          else
            super()
          end

        end

        # Define the setter
        define_method("#{field}=") do |val|
          
          if self.class.has_column?("#{field}_#{I18n.locale}")
            self["#{field}_#{I18n.locale}".to_sym] = val
          #if paperclip field
          elsif self.class.has_column?("#{field}_#{I18n.locale}_file_name")
            self.send("#{field}_#{I18n.locale}".to_sym, val)
          elsif self.class.has_column?("#{field}_file_name")
            self.send("#{field}".to_sym, val)
          else
            self[field.to_sym] = val
          end

        end
        
        # Define the getter for default_locale
        define_method("#{field}_#{I18n.default_locale}") do

          if self.class.has_column?("#{field}_#{I18n.locale}_file_name")
            self.send(field.to_sym)
          else
            self[field.to_sym]
          end

        end

        # Define the setter for default_locale
        define_method("#{field}_#{I18n.default_locale}=") do |val|

          if self.class.has_column?("#{field}_#{I18n.locale}_file_name")
            self.send(field.to_sym, val)
          else
            self[field.to_sym] = val
          end
          
        end
        
      end
    end
    
  end
  
end