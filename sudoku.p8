pico-8 cartridge // http://www.pico-8.com
version 15
__lua__

n = 3
n2 = n^2
solution = {}

function _init()
  pset(127, 127, 8)
  local initialtime = time()
  local sudoku = {}
  local sudokubis = {}

  solution = fillsolution()
  printsolution(solution)
  sudoku = solution
  sudokubis = solution
  -- wait()
  available = {}
  for i=1,(n^4) do
    available[i] = i
  end
  available = shuffle(available)
  local tries = 10
  while(tries > 0 and #available > 0) do
    -- printh('#available = '..#available)
    position = available[1]
    value = sudoku[position]
    sudoku[position] = 0
    -- printh('position = '..position)
    -- printh('value = '..value)
    del(available, position)
    printsolution(sudoku)
    sudokubis = sudoku
    if not solve(sudokubis) then
      sudoku[position] = value
      tries -= 1
    end
    -- wait(2)
  end
  printsolution(sudoku)
  printh('done!')
  print(flr(time() - initialtime)..' s', 0, 122, 7)
  pset(127, 127, 3)
end

function solve(sudoku)
  local sudoku_i = {}
  for v in all(sudoku) do
    add(sudoku_i, v)
  end
  -- printsolution(sudoku_i)
  local nzeroes = #sudoku_i
  local newvalues = #sudoku_i
  while nzeroes > 0 and newvalues > 0 do
    -- printsolution(sudoku_i)
    nzeroes = 0
    newvalues = 0
    for k, v in pairs(sudoku_i) do
      if v == 0 then
        local values = {}
        for i=1,(n^2) do
          values[i] = i
        end
        for k1, v1 in pairs(sudoku_i) do
          if ((k != k1) and (getsquare(k) == getsquare(k1) or (getrow(k) == getrow(k1)) or (getcolumn(k) == getcolumn(k1)))) then
            del(values, v1)
          end
        end
        if #values == 1 then
          sudoku_i[k] = values[1]
          -- printsolution(sudoku_i)
          newvalues +=1
        else
          nzeroes +=1
        end
      end
    end
  end
  return (nzeroes == 0)
end

function nzeroes(solution)
  local zeroes = 0
  for v in all(solution) do
    if v == 0 then
      zeroes += 1
    end
  end
  printh(zeroes)
  return zeroes
end

function _update()
  -- if (btn(4)) _init()
end

-->8

function wait(a)
  local firsttime = time()
  for i = 1,a*30 do flip()
  end
  local newtime = time()
end

function printsolution(solution)
  cls()
  for i=1,(n^4) do
    local column = getcolumn(i)
    local row = getrow(i)
    local square = getsquare(i)
    if solution[i] then
      printsquare(row, column, solution[i])
    end
    -- printsquare(row, column, row..'/'..column..'/'..square)
  end
  pset(127, 127, 8)
end

function updategrid()
  cls()
  solution = fillsolution()
  printsolution(solution)
end



function fillsolution()
  solution = {}
  o_available = {}
  for i=1,(n^4) do
    o_available[i] = i
    solution[i] = 0
  end
  -- available = shuffle(available)
  solution = fillposition(solution, o_available)
  return solution
end

function shuffle(tbl)
  size = #tbl
  for i = size, 1, -1 do
    local rand = flr(rnd(size)) + 1
    tbl[i], tbl[rand] = tbl[rand], tbl[i]
  end
  return tbl
end

function printsquare(row, column, i)
  local square_size = flr(120 / n2)
  if (n < 4) then
    rect(row * square_size, column * square_size, square_size * (row + 1), square_size * (column + 1), 7)
  end
  if i != 0 then
    print(i, (column + 1/4) * square_size, (row + 1/4) * square_size)
  end
end

function getcolumn(i)
  return (i-1) % (n2)
end

function getrow(i)
  return flr((i-1) / (n2))
end

function getsquare(i)
  return flr(getcolumn(i) / n) + (n * flr(getrow(i) / n))
end

function checkconflicts (solution, position, value)
  local square = getsquare(position)
  local row = getrow(position)
  local column = getcolumn(position)
  for currentposition, currentvalue in pairs(solution) do
    if ((currentvalue == value) and (currentposition != position) and (square == getsquare(currentposition) or (row == getrow(currentposition)) or (column == getcolumn(currentposition)))) then
      -- printh('conflict in position '..position)
      -- printh('with position '..currentposition)
      -- printh('with value '..value)
      -- printh('squares '..square..' - '..getsquare(currentposition))
      -- printh('rows '..row..' - '..getrow(currentposition))
      -- printh('columns '..column..' - '..getcolumn(currentposition))
      -- printh('---')
        return true
    end
  end
  return false
end

function fillposition(solution, available)
  -- printsolution(solution)
  if (#available == 0) then
    return solution
  end
  local position = available[1]
  del(available, position)
  -- printh('----position: '..position)
  local values = {}
  for i=1,(n^2) do
    values[i] = i
  end
  while (#values > 0) do
    local value = values[flr(rnd(#values)) + 1]
    del(values, value)
    if (not checkconflicts(solution, position, value)) then
      solution[position] = value
      local newsolution = fillposition(solution, available)
      if (newsolution) then
        -- printh('----position: '..position)
        -- printh('----value: '..value)
        return newsolution
      end
    end
  end
  unshift(available, position)
  solution[position] = 0
  -- printh('----position: '..position)
  -- printh('----not found')
  return false
end

function unshift(tbl, v)
  add(tbl, v)
  local size = #tbl
  for i = size, 2, -1 do
    tbl[i], tbl[i-1] = tbl[i-1], tbl[i]
  end

end
