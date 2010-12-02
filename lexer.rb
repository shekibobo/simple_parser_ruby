#!/usr/ruby
# Lexer written by Joshua Kovach
# Version 0.10.07.15
# for CIS 675 - Compilers Construction with Dr. Adams
#
# Language Grammar: 
# 
# program ::= stmt_list
# stmt_list ::= stmt ";" stmt_list
#            | nil   
# stmt ::=     id ":=" expr
#            | "if" expr "then" stmt
#            | "while" expr "do" stmt
#            | "begin" stmt_list "end"
# expr ::=    id "==" id
#           | id "!=" id
#           | id 
# 
require 'set'

class Lexer
  #
  # user inputs the file to be parsed, and initializer sets up our parsed and 
  # unparsed strings, as well as our constants and gets the first token from
  # the input string
  # 
  def initialize

    x = get_file_data
    print "#{x}"
    print "\nBegin Parsing...\n"


    #testing input
    # x = "x := y; if x == z then while a != b do begin a := d; e := f; end;"

    @unparsed = x
    @parsed = ""
    
    # K stands for KEYWORD
    # this contains all the known identifiers for the language
    @K = { :break => /^\s*;\s*/, :assign => /^\s*:=\s*/, 
      :if => /^\s*if\s+/, :while => /^\s*while\s+/, :begin => /^\s*begin\s+/,
      :then => /^\s*then\s+/, :do => /^\s*do\s+/, :end => /^\s*end\s*/,
      :eq => /^\s*==\s*/, :n_eq => /^\s*!=\s*/, :id => /^\s*[a-z][\w\d]*\s*/ }
    
    # these are valid patterns for beginning and following identifiers
    @FIRST_STMT = /(^if)|(^while)|(^begin)/
    @FOLLOW_STMT = /(^then)|(^do)|(^end)/
    
    # initializes the first token
    @token = get_token
    
  end
  
  # publicly accessible variables
  attr_reader :token, :parsed, :unparsed, :K, :FIRST_STMT, :FOLLOW_STMT
    
  # 
  # reads file data and returns it as a continuous string on one line.
  # not entirely optimal, but for some reason, the parser doesn't like when the
  # data string extends beyond one line.
  #
  def get_file_data
    print "Enter filename: "
    file = File.open(gets.chomp, "r")
    print "Filename '#{file.path}:\n'"
    x = ""
    file.each_line do |line|
      x += line.chomp
    end
    file.close
    x
  end
  
  # 
  # accepts the current token if it's expected and gets the next token in the string
  # :throws unexpected token exception
  # prints whether a particular identifier is accepted or rejected
  def accept(expected)
    # print "#{expected}(e) === #{@token}(t) = #{expected === @token}\n"
    # if expected === @token  # used if expected ever needs to be an /re/
    if @token == expected # replaced above 'if' statement
      print " accepted\n"
      @token = get_token
    else
      print "rejected\n"
      raise Exception.new("unable to accept token: expecting '#{expected}', got '#{@token}'")
    end
  end # accept
  
  # 
  # gets the next token that matches a valid expected pattern in the string, 
  # sets it to parsed, and sets the unparsed to the remaining data string
  #
  # :throws unrecognized lexeme exception
  # :returns a the stripped lexeme as a string
  #
  def get_token
    token = ""
    @K.each do |key, id|
      token = @unparsed.match(id) # this will be a MatchData type
      if token and @unparsed != ""
        @unparsed = token.post_match
        @parsed += ":#{key}(#{token.to_s.strip}) "
        print ":#{key}(#{token.to_s.strip}) "
        break
      end
    end
    if token == nil and @unparsed != ""
      raise Exception.new("Error: unrecognized lexeme '#{(@unparsed.match /\S+\s*/).to_s.strip}'")
    end
    token.to_s.strip
  end
end # Lexer

=begin # for lexer testing #
  def main
    lexer = Lexer.new
    until lexer.unparsed == ""
      token = lexer.get_token
      if token.match lexer.FIRST_STMT and !token.match lexer.FOLLOW_STMT
        print "#{token}\n"
      end
    end
    print lexer.parsed
  end
  
  main
=end