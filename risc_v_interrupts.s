.data 

# Messages
msg_1:		 .asciz		 "Please take a deep breath       "
msg_2:		 .asciz		 "Please drink some water         "
msg_3:		 .asciz	 	 "Please give your eyes a break   "

# Timer Related
timeNow: 	 .word 		 0xFFFF0018     # current time
cmp: 		 .word		 0xFFFF0020	# time for new interrupt

.text

# Display Related
.eqv OUT_CTRL 0xffff0008
.eqv OUT 0xffff000C

main:
# Set time to trigger interrupt to be 5000 milliseconds (5 seconds)
li s0, 0xFFFF0018
li s8, 0xFFFF0020
lw s1, 0(s0) # 5000 milliseconds
li s9, 5000
add s1, s1, s9
sw s1, 0(s8) # set timer value for interrupt

# Set the handler address and enable interrupts
la t0, timer_handler

csrrw zero, utvec, t0
csrrsi zero, uie, 0x10 # set bit 4 in uie to enable interrupt
csrrwi zero, ustatus, 1 # set interrupt enable bit

# Loop over the messages
addi s2, zero, 0 # indicator for 5 seconds passed
la s3, msg_1 # initial message register
li s5, 0xffff0008 # Transmitter control register
li s6, 0xffff000c # Transmitter data register (load key into here)
li s7, 268501088 # Comparison register
li t2, 0
li t3, 32

LOOP:
	beqz s2, LOOP
	
	jal choose
	
# Print message to ASCII display	
LOOP_BYTES:
	lb s4, 0(s3) # Load in letter
	beqz s5, LOOP_BYTES # Wait until ready
	sw s4, 0(s6) # Print letter
	addi s3, s3, 1 # Move to next byte
	addi t2, t2, 1
	bne t2, t3, LOOP_BYTES
	
	li t2, 0 # Reset loop counter
	addi s2, s2, -1 # Reset flag
	j LOOP

# Ops
choose:
	beq s3, s7, minus
	jr ra
minus:
	addi s3, s3, -96
	jr ra

timer_handler:
# Push registers to the stack
	# Saving used registers
	addi sp, sp -16
	sw s0, 0(sp)
	sw s1, 4(sp)
	sw s8, 8(sp)
	sw s9, 12(sp)

	# Indicate that 5 seconds have passed
	addi s2, s2, 1
	
	li s0, 0xFFFF0018 # current time
	li s8, 0xFFFF0020 # comparison time
	
	lw s1, 0(s0)
	li s9, 5000
	add s1, s1, s9
	sw s1, 0(s8)

	# Pop registers from the stack
	lw s0, 0(sp)
	lw s1, 4(sp)
	lw s8, 8(sp)
	lw s9, 12(sp)
	addi sp, sp, 16
	
	uret
