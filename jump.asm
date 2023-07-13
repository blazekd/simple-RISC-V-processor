jal aaa
addi x6,x6,1 #
beq zero,x6, end
back:

addi x7,zero, 2 #

beq zero, zero, end1

addi x9, zero, 4

jal end
addi x14, zero, 9

aaa:
addi x8,zero, 3 #
jalr ra
addi x13, zero, 8 #
jalr ra, ra, 4
addi x10, zero, 5

#jalr rd, rs1, imm11:0
addi x11, zero, 6

end1:
jalr ra

end:
jal end

addi x12, x12, 7 #

#realend:
#jal realend