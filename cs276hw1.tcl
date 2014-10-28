# Create a simulator object
set ns [new Simulator]

# Open the nam trace file
set nf [open hw1.nam w]
$ns namtrace-all $nf

#Open the trace file (before you start the experiment!)
set tf [open p1trace.tr w]
$ns trace-all $tf

#Define a 'finish' procedure
proc finish {} {
        global ns nf
        $ns flush-trace
        #Close the NAM trace file
        close $nf
        #Execute NAM on the trace file
        exec nam hw1.nam &
        exit 0
}

# Insert your own code for topology creation
# and agent definitions, etc. here
####################################################################################
#                         N1                      N4                     
#                           \                    /
#                            \                  /
#                             N2--------------N3
#                            /                  \
#                           /                    \
#                         N5                      N6

$ns color 23 Blue
$ns color 14 Green
$ns color 56 Red

# Create six nodes
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]

# Create a duplex link between the nodes 
$ns duplex-link $n1 $n2 10Mb 10ms DropTail    
$ns duplex-link $n2 $n5 10Mb 10ms DropTail 
$ns duplex-link $n2 $n3 10Mb 10ms DropTail 
$ns duplex-link $n3 $n4 10Mb 10ms DropTail 
$ns duplex-link $n3 $n6 10Mb 10ms DropTail 

# Topology
$ns duplex-link-op $n1 $n2 orient right-down 
$ns duplex-link-op $n2 $n5 orient left-down
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n3 $n4 orient right-up
$ns duplex-link-op $n3 $n6 orient right-down

#Setup a UDP connection N2-N3
set udp [new Agent/UDP]
$ns attach-agent $n2 $udp
set null [new Agent/Null]
$ns attach-agent $n3 $null
$ns connect $udp $null
$udp set fid_ 23

#Setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 6mb
$cbr set random_ false

# Setup a TCP connection N1-N4
set tcp14 [new Agent/TCP]
$tcp14 set class_ 2
$ns attach-agent $n1 $tcp14
set sink4 [new Agent/TCPSink]
$ns attach-agent $n4 $sink4
$ns connect $tcp14 $sink4
$tcp14 set fid_ 14

# Setup a TCP connection N5-N6
set tcp56 [new Agent/TCP]
$tcp56 set class_ 2
$ns attach-agent $n5 $tcp56
set sink6 [new Agent/TCPSink]
$ns attach-agent $n6 $sink6
$ns connect $tcp56 $sink6
$tcp56 set fid_ 56

# Setup a CBR over TCP connection
set cbr14 [new Application/Traffic/CBR]
$cbr14 attach-agent $tcp14
$cbr14 set type_ CBR
$cbr14 set packet_size_ 1000
$cbr14 set rate_ 2mb
$cbr14 set random_ false

# Setup a CBR over TCP connection
set cbr56 [new Application/Traffic/CBR]
$cbr56 attach-agent $tcp56
$cbr56 set type_ CBR
$cbr56 set packet_size_ 1000
$cbr56 set rate_ 2mb
$cbr56 set random_ false


####################################################################################
# Call the finish procedure after 5 seconds simulation time

$ns at 0.2 "$cbr start"
$ns at 0.2 "$cbr14 start"
$ns at 0.2 "$cbr56 start"
$ns at 9.5 "$cbr14 stop"
$ns at 9.5 "$cbr56 stop"
$ns at 9.5 "$cbr stop"
$ns at 10.0 "finish"

# Print CBR packet size and interval
puts "CBR packet size = [$cbr set packet_size_]"
puts "CBR interval = [$cbr set interval_]"

# Run the simulation
$ns run

close $tf