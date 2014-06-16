require 'mkmf'
require File.expand_path '../compiler/generic_compiler', __FILE__
require File.expand_path '../compiler/gcc', __FILE__
require File.expand_path '../compiler/clang', __FILE__

module Libv8
  module Compiler
    KNOWN_COMPILERS = [
                       'c++',
                       'g++48', 'g++46', 'g++44', 'g++',
                       'clang++',
                      ]

    module_function

    def system_compilers
      available_compilers *Compiler::KNOWN_COMPILERS
    end

    def available_compilers(*compiler_names)
      compiler_paths = compiler_names.map { |name| find name }.reject &:nil?
    end

    def find(name)
      return nil if name.empty?
      path   = `which #{name}`
      status = $?
      path.chomp!
      determine_type(path).new(path) if status.success?
    end

    def determine_type(compiler_path)
      compiler_version = `#{compiler_path} -v 2>&1`

      case compiler_version
      when /\bclang\b/i then Clang
      when /^gcc/i      then GCC
      else                   GenericCompiler
      end
    end
  end
end
