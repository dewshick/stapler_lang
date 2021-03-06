module ParseStapler where

--import System.IO
import Control.Monad
import Text.ParserCombinators.Parsec
import Text.ParserCombinators.Parsec.Expr
import Text.ParserCombinators.Parsec.Language
import qualified Text.ParserCombinators.Parsec.Token as Token


data AExpr = IntConst Integer | ABinary ABinOp AExpr AExpr | Assign String AExpr deriving (Show)
data ABinOp = Add | Subtract | Multiply | Divide deriving (Show)

reservedBinOps   = ["+", "-", "*", "%"]
reservedBinOpAdt = [Add, Subtract, Multiply, Divide]
binopToAdt = zip reservedBinOps reservedBinOpAdt

languageDef = emptyDef { Token.reservedOpNames = reservedBinOps }
lexer = Token.makeTokenParser languageDef

reservedOp = Token.reservedOp lexer
parens     = Token.parens     lexer
integer    = Token.integer    lexer
semi       = Token.semi       lexer
whiteSpace = Token.whiteSpace lexer

staplerParser :: Parser [AExpr]
staplerParser = whiteSpace >> sepBy1 aExpression semi

aExpression = buildExpressionParser aOperators aTerm

aOperators = let binOpParser (op, datatype) = Infix (reservedOp op >> return (ABinary datatype)) AssocLeft
                 binOps = map binOpParser binopToAdt
             in [binOps]

aTerm = parens aExpression <|> liftM IntConst integer


parseString :: String -> [AExpr]
parseString str =
  case parse staplerParser "" str of
    Left e  -> error $ show e
    Right r -> r

evalExprs :: [AExpr] -> Integer
evalExprs es = foldl (\n e -> evalExpr e) 0 es

evalExpr :: AExpr -> Integer
evalExpr (IntConst i) = i
evalExpr (ABinary op e1 e2) = (evalBinOp op) (evalExpr e1) (evalExpr e2)

evalBinOp op = case op of
  Add -> (+)
  Subtract -> (-)
  Multiply -> (*)
  Divide -> div

evalString :: String -> Integer
evalString str = evalExprs $ parseString str

repl = do
  l <- getLine
  if null l
  then return ()
  else (putStrLn $ show $ evalString l) >> repl