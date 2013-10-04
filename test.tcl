#
# Copyright (C) 2013 Maria Marin <m.marin at jacobs-university.de>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# TODO:
# compare function like diff between the outputted files
# put v1 and kb as variables and not hardcoded
# skip empty lines in data file and comment lines in data file
# write this as a pluggin
# source test.tcl ; t_loadlist kb.rlist

proc t_loadlist {filename} {
	set fp [open $filename]
	set repnames [list ]
	# label add bonds will not inform us of an existing label therfore we 
	# must delete all labels first  
	label delete Bonds all
	while {-1 != [gets $fp line]} {
		#parsing line into variables
		lassign [split $line] res1 at1 res2 at2
		set sel1 [atomselect top "resid $res1 and name $at1"]
		set sel2 [atomselect top "resid $res2 and name $at2"]
		set index1 [$sel1 get index]
		if {$index1 eq ""} {
			puts stderr "no index for $res1 and $at1"
			continue
		} 
		set resn1 [$sel1 get resname]
		set index2 [$sel2 get index]
		if {$index2 eq ""} {
			puts stderr "no index for $res2 and $at2"
			continue
		}
		set resn2 [$sel2 get resname]
		set filename "kb_v1_${resn1}_${at1}_${resn2}_${at2}.dat"
		if [catch {label add Bonds 0/$index1 0/$index2}] {
			puts stderr "cannot add Bonds label for 0/$index1 0/$index2"
			continue
		}
		# label add bonds does not return the label number therefore
		# retrieving the last created 
		set labelnum [expr [llength [label list Bonds]] - 1] 
		# puts $labelnum
		label graph Bonds $labelnum $filename
		# exec  gnuplot -e "plot \"$filename\"" -p
		# drawing method for the first residue of the line
		mol representation Licorice 
		mol color Name
		mol selection resid $res1
		mol addrep top
		set repid1 [expr [molinfo top get numreps] - 1]
		set repname1 [mol repname top $repid1]
		# set drawing method for the second residue of the line
		mol representation Licorice 
		mol color Name
		mol selection resid $res2
		mol addrep top
		set repid2 [expr [molinfo top get numreps] - 1]
		set repname2 [mol repname top $repid2]
		lappend repnames [list $repname1 $repname2] 
	}
	close $fp
	return $repnames
}


proc t_clear {repnames} {
	foreach names $repnames {
		lassign $names repname1 repname2
		puts $names
		set repid1 [mol repindex top $repname1] 
		set repid2 [mol repindex top $repname2] 
		mol delrep $repid1 top  
		mol delrep $repid2 top 
	} 
}
