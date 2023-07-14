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

add t0, zero, zero # counting of pixels - init to zero


merge_mult: # width times add height (count pixels == i in for cycle)
	beq zero, t3, merge_cont # if t3 == 0 jump to merge_cont
	add t0, t0, t4	# add height 
	addi t3, t3, -1	# t3 -= 1
	beq zero, zero, merge_mult # always jump to merge_mult
	
merge_cont:
add a0, t0, zero # set out register (a0) to pixel count
add t4, t0, zero # set i variable in for cycle to pixel count

merge_for: # for cycle

	beq zero, t4, merge_done # t4 (i varible) == 0 => jump to merge_done
	addi t1, t1, 4 # next img1 pixel
	addi t2, t2, 4 # next img2 pixel
	addi t6, t6, 4 # next imgOut pixel
	
	lw t0, (t1) # load img1 pixel
	lw t5, (t2) # load img2 pixel
	
	adduqb t5, t0, t5 # add channels together (using custom adduqb instruction)
	
	addi t0, zero, 8 # variable for shifts - 2 bytes (8 bits)
	
	sll t5, t5, t0 # shift logical left and then right by 2 bytes
	srl t5, t5, t0 # both shifts combined will make the 2 most significant bytes 0
	
	addi t0, zero, 255 # prepare 0xff value for alpha channel
	addi t3, zero, 24 # varibale for shift for alpha channel 6 bytes (24 bits)
	sll t0, t0, t3 # logical shift left to make alpha channel (0xff000000)
	add t5, t5, t0 # set alpha channel on pixel to 0xff
	
	sw t5, (t6) # save pixel to outImag
	

	addi t4, t4, -1 # i--
	beq zero,zero, merge_for # always jump to merge_for

merge_done:          
ret                   # return from the routine
#------------------------------------------------------------
main:

lw a0, 4 # load img1 address to in parameter (register a0) from address 0x00000004
lw a1, 8 # load img2 address to second in parameter (register a1) from address 0x00000008
lw a2, 12 # load outImg address to third in parameter (register a2) from address 0x0000000c


jal merge # start routine merge

sw a0, 16 # save pixel count to address 0x00000010


