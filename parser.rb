# 
# Parser written by Joshua Kovach
# Version 0.10.07.15
# for CIS 675 - Compilers Construction with Dr. Adams
#

# Language Grammar: 
# 
# program ::= stmt_list
# stmt_list ::= stmt ";" stmt_list
#            | nil   
# stmt ::= id ":=" expr
#            | "if" expr "then" stmt
#            | "while" expr "do" stmt
#            | "begin" stmt_list "end"
# expr ::= id "==" id
#           | id "!=" id
#           | id 
# 
require 'lexer.rb'

class Parser

  #
  # This starts us off with a lexer, which will ask for a file to parse.
  # A local reference is made to the keyword list @K.  We also run the parser
  # for 'program' grammar.
  # 
  def initialize
    @lexer = Lexer.new
    @K = @lexer.K
    program
  end
  
  # 
  # Grammar for 'program'
  # program ::= stmt_list
  # 
  def program
    stmt_list
  end
  
  #
  # Grammar for statement lists
  # stmt_list ::= stmt ';' stmt_list
  #             | nil
  # 
  def stmt_list
    #
    # if we've reached the end of the file or we see an 'end' marker to a block
    # of statements, then we know we've seen the end of this statement list
    # otherwise, parse the grammar as explained
    if @lexer.unparsed != "" and !@lexer.token.match @K[:end]
      stmt
      @lexer.accept ";"
      stmt_list
    elsif @lexer.token.match @K[:end]
      # this door's locked, move on to the next one
      # the block of statements has ended if we see 'end' in a legal position
    else # the story is over
      print "program complete\n"
      print "#{@lexer.parsed}"
    end
  end # stmt_list
  
  # 
  # Grammar for statements
  # stmt ::= id ':=' expr               # assignment - unique in the set
  #        | 'if' expr 'then' stmt      # if-then
  #        | 'while' expr 'do' stmt     # while-do
  #        | 'begin' stmt_list 'end'    # statement block - requires special breaking conditions
  #
  # special handling is implemented for statements beginning with a valid :id
  # since extra verification is required to ensure that it doesn't match 
  # reserved words and that it is followed by its only legal follower in 
  # the statement grammar.
  # 
  def stmt
    # 
    # make sure that the keywords are valid statement starters
    # if so, start parsing the statement according to the grammar
    # :throws unidentified statement exception
    #
    if @lexer.token.match @lexer.FIRST_STMT and !@lexer.token.match @lexer.FOLLOW_STMT
      case @lexer.token
      when 'if'
        @lexer.accept 'if'
        expr
        @lexer.accept 'then'
        stmt
      when 'while'
        @lexer.accept 'while'
        expr
        @lexer.accept 'do'
        stmt
      when 'begin'
        @lexer.accept 'begin'
        stmt_list
        @lexer.accept 'end'
      else
        raise Exception.new "error, unidentified statement '#{@lexer.token}'"
      end
    elsif @lexer.token.match @K[:id] # and @lexer.unparsed.match @K[:assign]
      id
      @lexer.accept ':='
      expr
    elsif @lexer.token == ""
      raise Exception.new "error: unexpected statement: '#{@lexer.token}'"
    end
  end # stmt
  
  # 
  # Grammar for expressions
  # expr ::= id '==' id
  #        | id '!=' id
  #        | id
  #
  # accepts at least one :id.  if the following token is :eq or :n_eq, we will
  # accept that and expect another :id after that.
  #
  def expr
    id
    if (@lexer.token.match @K[:eq] or @lexer.token.match @K[:n_eq])
      oper
      id
    end
  end # expr
  
  # 
  # Grammar for identifiers
  # id ::= [a-z][\w\d]* as long as it doesn't match a reserved word in @K
  #
  # :throws invalid identifier exceptions if it matches a reserved word or
  # doesn't match the pattern.
  #
  def id
    if ( @lexer.token.match(@K[:id]) &&
        !@lexer.token.match(@lexer.FIRST_STMT) &&
        !@lexer.token.match(@lexer.FOLLOW_STMT) )
      @lexer.accept @lexer.token
    elsif @lexer.token.match @lexer.FIRST_STMT or @lexer.token.match @lexer.FOLLOW_STMT
      # in theory, if you replaced an :id with the word 'end' in the program,
      # this exception should be raised.  however, instead we get a lexical
      # exception where it asks for ';' and gets ':=' instead.  inspection required.
      raise Exception.new "syntax error, invalid identifier: '#{@lexer.token}' " +
        "is a reserved word."
    else
      raise Exception.new "syntax error, invalid identifier: '#{@lexer.token}'"
    end
  end
  
  # 
  # Grammar for operators
  # oper ::= '==' | '!='
  # 
  def oper
    if @lexer.token.match @K[:eq]
      @lexer.accept '=='
    elsif @lexer.token.match @K[:n_eq]
      @lexer.accept '!='
    else
      raise Exception.new "syntax error, unexpected operator: '#{@lexer.token}'"
    end
  end # oper
end

#=============================================================================#
# begin actual program with exception reporting
#=============================================================================#
begin
  p = Parser.new 
rescue Exception => e
  print e.message
end