module ParseStapler where

--import System.IO
--import Control.Monad
--import Text.ParserCombinators.Parsec
--import Text.ParserCombinators.Parsec.Expr
import Text.ParserCombinators.Parsec.Language
import qualified Text.ParserCombinators.Parsec.Token as Token


data AExpr = Seq [AExpr] | IntConst Integer | ABinary ABinOp AExpr AExpr deriving (Show)
data ABinOp = Add | Subtract | Multiply | Divide deriving (Show)

languageDef = emptyDef { Token.reservedOpNames = ["+", "-", "*", "%"] }
lexer = Token.makeTokenParser languageDef

reservedOp = Token.reservedOp lexer
parens     = Token.parens     lexer
integer    = Token.integer    lexer
semi       = Token.semi       lexer
whiteSpace = Token.whiteSpace lexer