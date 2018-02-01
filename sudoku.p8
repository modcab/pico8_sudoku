pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
-- sudoku
-- by modestocaballero

n = 2
n2 = n^2
solution = {}
initialtime = 0
time_generation = 0
removed = {}
square_size = 10
tries = 1
x_padding = 0
y_padding = 0


game = {
  state = 1,
  menu = 1,
  generation = 2,
  generating = 3,
  game = 4,
}

grid = {
  solution = {},
  active = {
    row = 0,
    column = 0
  }
}

headers = {}
sudoku = {}

overlay = {
  enabled = false,
  selected = 1,
}

function _init()
  setn(2)
  overlay_disable()
end

function _update()
  if (game.state == game.menu) then
    update_menu()
  elseif (game.state == game.generation) then
    update_generation()
  elseif (game.state == game.game) then
    update_game()
  end
end

function getifromrowcolumn(row, column)
  return (n2 * row) + column + 1;
end

function setn(new_n)
  n = new_n
  n2 = n^2
  if (n == 2) then
    tries = 3
    square_size = 10
    y_padding = 0
  else
    tries = 10
    square_size = 10
    y_padding = 0
  end
  sudoku_w = square_size * n2
  x_padding = 64 - flr(sudoku_w / 2)
end

function _draw()
  if (game.state == game.menu) then
    draw_menu()
  elseif (game.state == game.generation) then
    draw_generation()
  elseif (game.state == game.game) then
    draw_game()
  end
end

function printoverlay()
  if (overlay_is_enabled()) then
    local str = ''
    local color = 7
    local padding = 64 - (n2 * 4)
    for c = 1,n2 do
      if (overlay.selected == c) then
        color = 12
      end
      print(c, padding + (c - 1) * 8, sudoku_w + 10, color)
      color = 7
    end
  end
end

function printactivesquare()
  local row = grid.active.row
  local column = grid.active.column
  local square = rowcolumnsquare(row, column)
  printsquare(row, column, square, 0, flr(rnd(15)) + 1)
end

function solve(sudoku)
  local sudoku_i = {}
  for v in all(sudoku) do
    add(sudoku_i, v)
  end
  local nzeroes = #sudoku_i
  local newvalues = #sudoku_i
  while nzeroes > 0 and newvalues > 0 do
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
  return zeroes
end

-->8
-- menu
function update_menu()
  if (btnp(0) or btnp(1)) then
    if (n == 2) then
      setn(3)
    else
      setn(2)
    end
  end
  if (btnp(4)) then
    game.state = game.generation
  end
  return
end

function draw_menu()
  cls()
  center_print('choose sudoku type', 30)
  center_print(n..'x'..n, 50)
  center_print('\x8b\x91 to select', 70)
  center_print('\x8e to confirm', 80)
  return
end

-->8
-- generation

function update_generation()
  game.state = game.generating
  pset(127, 127, 8)
  initialtime = time()
  local sudokubis = {}
  local values_removed = {}
  local removed_since_last_try = 0
  local times_solved = 0

  solution = fillsolution()
  sudoku = solution
  available = {}
  for i=1,(n^4) do
    available[i] = i
  end
  available = shuffle(available)
  while(tries > 0 and #available > 0) do
    position = available[1]
    value = sudoku[position]
    sudoku[position] = 0
    del(available, position)
    unshift(removed, position)
      if (not solve(sudoku)) then
        del(removed, position)
        sudoku[position] = value
        add(available, position)
        tries -= 1
      else
      end
      times_solved +=1

    end
    for k, v in pairs(sudoku) do
      if (v != 0) add(headers, k)
    end
    for v in all(headers) do
    end

  game.state = game.game
  time_generation = flr(time() - initialtime)..' s'
end

function draw_generation()
  cls()
  center_print('generating your sudoku,', 40)
  center_print('please wait', 50)
end

-->8
-- game

function update_game()
  if (overlay_is_enabled()) then
    -- overlay enabled.
    -- move left and right
    if (btnp(0)) then
      overlay.selected = overlay.selected - 1
      if (overlay.selected < 1) overlay.selected = n2
    end
    if (btnp(1)) then
      overlay.selected = overlay.selected + 1
      if (overlay.selected > n2) overlay.selected = 1
    end
    -- select
    if (btnp(4)) then
      overlay_disable()
      position = getifromrowcolumn(grid.active.row, grid.active.column)
      sudoku[position] = overlay.selected
    end
    -- cancel
    if (btnp(5)) then
      overlay_disable()
    end
  else
    if (btnp(0)) then
      grid.active.column = (grid.active.column - 1) % n2
    end
    if (btnp(1)) then
      grid.active.column = (grid.active.column + 1) % n2
    end
    if (btnp(2)) then
      grid.active.row = (grid.active.row - 1) % n2
    end
    if (btnp(3)) then
      grid.active.row = (grid.active.row + 1) % n2
    end
    if (btnp(4)) then
      overlay_enable()
    end
  end
end

function draw_game()
  cls()
  printsolution(sudoku)
  printactivesquare()
  printoverlay()
  print(time_generation, 0, 122, 7)
  pset(127, 127, 3)
end

-->8
function printsolution(solution)
  for v in all(headers) do
  end
  for k,v in pairs(solution) do
  end

  cls()
  local y = 0
  for i=1,(n^4) do
    y+=1
    local column = getcolumn(i)
    local row = getrow(i)
    local square = getsquare(i)
    if solution[i] then
      if hasvalue(headers, i) then
        printheader(row, column, square, solution[i])
      end
      printsquare(row, column, square, solution[i])
    end
  end
  pset(127, 127, 8)
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

function printsquare(row, column, square, i, c)
  c = c or 7
  x0 = column * square_size + (square % n) + x_padding
  y0 = row * square_size + flr(square / n)
  x1 = square_size * (column + 1) + (square % n) + x_padding
  y1 = square_size * (row + 1) + flr(square / n) + y_padding
  rect(x0, y0, x1, y1, c)
  if i != 0 then
    x = (column + 1/4) * square_size + (square % n) + x_padding
    y = (row + 1/4) * square_size + flr(square / n) + y_padding
    print(i, x, y, 7)
  end
end

function overlay_disable()
  printh('overlay_disable')
  overlay.enabled = false
end

function overlay_enable()
  printh('overlay_enable')
  overlay.enabled = true
end

function overlay_is_enabled()
  return overlay.enabled == true
end

function printheader(row, column, square, i)
  x0 = column * square_size + (square % n) + 1 + x_padding
  y0 = row * square_size + flr(square / n) + 1 + y_padding
  x1 = square_size * (column + 1) + (square % n) - 1 + x_padding
  y1 = square_size * (row + 1) + flr(square / n) - 1 + y_padding
  rectfill(x0, y0, x1, y1, 12)
  if i != 0 then
    x = (column + 1/4) * square_size + (square % n) + x_padding
    y = (row + 1/4) * square_size + flr(square / n) + y_padding
    print(i, x, y, 7)
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

function rowcolumnsquare(row, column)
  local n1 = flr(column / n)
  local n2 = n * flr(row / n)
  return n1 + n2
end

function checkconflicts (solution, position, value)
  local square = getsquare(position)
  local row = getrow(position)
  local column = getcolumn(position)
  for currentposition, currentvalue in pairs(solution) do
    if ((currentvalue == value) and (currentposition != position) and (square == getsquare(currentposition) or (row == getrow(currentposition)) or (column == getcolumn(currentposition)))) then
        return true
    end
  end
  return false
end

function fillposition(solution, available)
  if (#available == 0) then
    return solution
  end
  local position = available[1]
  del(available, position)
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
        return newsolution
      end
    end
  end
  unshift(available, position)
  solution[position] = 0
  return false
end

-->8
-- Util.
function center_print(text, y, c)
  c = c or 7
  local padding = 64 - flr((#text * 4) / 2)
  print(text, padding, y, c)
end
-- Stops execution for a seconds
function wait(s)
  local firsttime = time()
  for i = 1, s * 30 do flip()
  end
  local newtime = time()
end

-- Adds an element at the beginning of an array.
function unshift(tbl, v)
  add(tbl, v)
  local size = #tbl
  for i = size, 2, -1 do
    tbl[i], tbl[i-1] = tbl[i-1], tbl[i]
  end
end

function hasvalue(tbl, search)
  for current in all(tbl) do
    if (current == search) return true
  end
  return false
end
