j main                 # jump to main
#------------------------------------------------------------
# merge:
# Inputs: a0 - inputImgA address, a1 - inputImgB address, a2 inputOut address
# Outputs: a0 - total pixels
merge:

add t1, a0, zero # load img1 address
add t2, a1, zero # load img2 address
add t6, a2, zero # load outImg address

lw t3, (t1) # load img1 header
sw t3, (t6) # save outImg header

addi t1, t1, 4 # move to address of img1 width
lw t3, (t1) # load img1 width

addi t6, t6, 4 # move to address of outImg width 
sw t3, (t6) # save outImg width

addi t1, t1, 4 # move to address of img1 height
lw t4 , (t1) # load img1 height 

addi t6, t6, 4 # move to address of outImg height
sw t4, (t6) # save outImg height

# all of the above are same for all 3 imgs

addi t2, t2, 8 # move to addres of img2 height (so we can start merging pixels)

# t4 = height, t3 = width, t0 = pixel count
#add t0, t4, zero # uložení výšky k pøièítání 
#addi t3, t3, -1	# b - 1 - jednou už tam je

add t0, zero, zero # counting of pixels - init to zero


merge_mult: # width times add height (count pixels == i in for cycle)
	beq zero, t3, merge_cont # if t3 == 0 jump to merge_cont
	add t0, t0, t4	# add height 
	addi t3, t3, -1	# t3 -= 1
	beq zero, zero, merge_mult # always jump to merge_mult
	
merge_cont:
add a0, t0, zero # set out parameter (pixel count)
add t4, t0, zero # set i variable in for cycle to pixel count

merge_for: # for cycle

	beq zero, t4, merge_done # t4 (i varible) == 0 => jump to merge_done
	addi t1, t1, 4 # next img1 pixel
	addi t2, t2, 4 # next img2 pixel
	addi t6, t6, 4 # next imgOut pixel
	
	lw t0, (t1) # load img1 pixel
	lw t5, (t2) # load img2 pixel
	
	adduqb t5, t0, t5 # add channels together (using custom adduqb instruction)
	
	addi t0, zero, 8 # posun
	
	sll t5, t5, t0 
	srl t5, t5, t0 # spolu s pøedchozím øádkem vynuluje první 2 byte
	
	addi t0, zero, 255
	addi t3, zero, 24 # posun pro alphu
	sll t0, t0, t3
	add t5, t5, t0 # nastaví alpha na 0x255
	
	sw t5, (t6) # uloží pixel do outu
	

	addi t4, t4, -1 # i++
	beq zero,zero, merge_for

merge_done:          
ret                   # return from the routine
#------------------------------------------------------------
main:

lw a0, 4 # load adresy img1
lw a1, 8 # load adresy img2
lw a2, 12 # load adresy out img


jal merge

sw a0, 16 # uložení šíøky*výšky


