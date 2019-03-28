function! s:ninja_prepare(mode, direction, count)
	let s:direction = a:direction
	let s:operator = v:operator
	let s:cursor_pos = getpos('.')
	let s:operatorfunc = &operatorfunc
	call feedkeys(a:count.a:mode)
endfunction

function! s:ninja_strike(mode)
	call setpos('.', s:cursor_pos)
	let &operatorfunc = s:operatorfunc
	let mode = a:mode == 'line' ? "'" : "`"
	if s:direction == ']'
		" Manually adjust for inclusive behaviour.
		" TODO: Find a cleaner solution
		let pos = getpos("'".s:direction)
		if mode == '`' && pos[2] == strlen(getline(pos[1]))
			" End marks end of line. Just use $.
			let mode = ''
			let s:direction = '$'
		else
			" Add one to the mark column position
			let pos[2] = pos[2] + 1
			call setpos("'".s:direction, pos)
		endif
	endif
	call feedkeys(s:operator.mode.s:direction)
endfunction

function! s:ninja_insert(mode)
	let op = a:mode == 'line' ? 'O' : 'i'
	call feedkeys('`['.op, 'n')
endfunction

function! s:ninja_begin(mode)
	call feedkeys('`[', 'n')
endfunction

function! s:ninja_append(mode)
	let op = a:mode == 'line' ? 'o' : 'a'
	call feedkeys('`]'.op, 'n')
endfunction

function! s:ninja_end(mode)
	call feedkeys('`]', 'n')
endfunction

function! s:map_expr(sid, type, direction, count)
	let map = ''
	let map .= "\<Esc>"
	let map .= ":\<C-U>call ".a:sid."ninja_prepare('".a:type."', '".a:direction."', '".a:count."')\<CR>"
	let map .= ":\<C-U>set operatorfunc=".a:sid."ninja_strike\<CR>g@"
	return map
endfunction

function! s:map(lhs, rhs, mode)
	if !hasmapto(a:rhs, a:mode)
		execute a:mode.'map '.a:lhs.' '.a:rhs
	endif
endfunction

onoremap <silent> <expr> <Plug>(ninja-left-foot-inner)  <SID>map_expr("<SID>", 'i', '[', v:count1)
onoremap <silent> <expr> <Plug>(ninja-left-foot-a)      <SID>map_expr("<SID>", 'a', '[', v:count1)
onoremap <silent> <expr> <Plug>(ninja-left-foot-Inner)  <SID>map_expr("<SID>", 'I', '[', v:count1)
onoremap <silent> <expr> <Plug>(ninja-left-foot-A)      <SID>map_expr("<SID>", 'A', '[', v:count1)
onoremap <silent> <expr> <Plug>(ninja-left-foot-gc)     <SID>map_expr("<SID>", 'g', '[', v:count1)c
onoremap <silent> <expr> <Plug>(ninja-right-foot-inner) <SID>map_expr("<SID>", 'i', ']', v:count1)
onoremap <silent> <expr> <Plug>(ninja-right-foot-a)     <SID>map_expr("<SID>", 'a', ']', v:count1)
onoremap <silent> <expr> <Plug>(ninja-right-foot-Inner) <SID>map_expr("<SID>", 'I', ']', v:count1)
onoremap <silent> <expr> <Plug>(ninja-right-foot-A)     <SID>map_expr("<SID>", 'A', ']', v:count1)
onoremap <silent> <expr> <Plug>(ninja-right-foot-gc)    <SID>map_expr("<SID>", 'g', ']', v:count1)c

nnoremap <silent> <Plug>(ninja-insert) :<C-U>set operatorfunc=<SID>ninja_insert<CR>g@
nnoremap <silent> <Plug>(ninja-append) :<C-U>set operatorfunc=<SID>ninja_append<CR>g@
nnoremap <silent> <Plug>(ninja-begin)  :<C-U>set operatorfunc=<SID>ninja_begin<CR>g@
nnoremap <silent> <Plug>(ninja-end)    :<C-U>set operatorfunc=<SID>ninja_end<CR>g@

if !exists('g:ninja_feet_no_mappings')
	call s:map('[i',  "<Plug>(ninja-left-foot-inner)",  'o')
	call s:map('[a',  "<Plug>(ninja-left-foot-a)",      'o')
	call s:map('[I',  "<Plug>(ninja-left-foot-Inner)",  'o')
	call s:map('[A',  "<Plug>(ninja-left-foot-A)",      'o')
	call s:map('[gc', "<Plug>(ninja-left-foot-gc)",     'o')
	call s:map(']i',  "<Plug>(ninja-right-foot-inner)", 'o')
	call s:map(']a',  "<Plug>(ninja-right-foot-a)",     'o')
	call s:map(']I',  "<Plug>(ninja-right-foot-Inner)", 'o')
	call s:map(']A',  "<Plug>(ninja-right-foot-A)",     'o')
	call s:map(']gc', "<Plug>(ninja-right-foot-gc)",    'o')

	call s:map('z[',  "<Plug>(ninja-insert)",  'n')
	call s:map('z]',  "<Plug>(ninja-append)",  'n')

	call s:map('[i',  "<Plug>(ninja-begin)i",  'n')
	call s:map('[a',  "<Plug>(ninja-begin)a",  'n')
	call s:map('[I',  "<Plug>(ninja-begin)I",  'n')
	call s:map('[A',  "<Plug>(ninja-begin)A",  'n')
	call s:map('[gc', "<Plug>(ninja-begin)gc", 'n')
	call s:map(']i',  "<Plug>(ninja-end)i",    'n')
	call s:map(']a',  "<Plug>(ninja-end)a",    'n')
	call s:map(']I',  "<Plug>(ninja-end)I",    'n')
	call s:map(']A',  "<Plug>(ninja-end)A",    'n')
	call s:map(']gc', "<Plug>(ninja-end)gc",   'n')
endif
