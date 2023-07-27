load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

;This script is in support of Nature Food article Clark et al., 2023 "The Optimal Climate Intervention Scenario for Crop Production Varies by Nation"
;This script currently takes 0.5 degree resolution netCDF file of production with units (crop,lat,lon) and outputs production per nation

IDtxttemp=asciiread("/glade/p/univ/urtg0006/processCLMcropoutput/newAgMERRA/matlab/nationid.txt",(/237,1/),"integer")
IDtxt=rm_single_dims(IDtxttemp)
;printVarSummary(IDtxt)

b=addfile("/glade/p/univ/urtg0006/processCLMcropoutput/newAgMERRA/matlab/gadm0.mask.nc4","r")
ID=b->gadm0
printVarSummary(ID)
IDtemp=new((/360,720/),integer)
IDtemp1=new((/360,720/),integer)
IDtemp=ID
IDtemp1(:,0:359)=IDtemp(:,360:719)
IDtemp1(:,360:719)=IDtemp(:,0:359)
ID(:,:)=IDtemp1(359:0,:)
IDnew=conform_dims((/7,360,720/),ID,(/1,2/))

c=addfile("path/to/file/ + historical_prod_2004-2014_0.5deg.nc","r")
ref=c->production
printVarSummary(ref)
printMinMax(ref,0)

output=new((/2,237/),double)

do n=0,236,1
nationref=where(ID.eq.IDtxt(n),rm_single_dims(ref(0,:,:)),ref@_FillValue)
nationreft=dim_sum_n(dim_sum_n(nationref,1),0)
nozeroconnationreft=where(nationreft(0).ne.0,nationreft(0),ref@_FillValue)

output(0,n)=IDtxt(n)
output(1,n)=nozeroconnationreft
end do
asciiwrite("maize_hist.txt",output)
print(output)


outputfile="maize_hist.nc"
setfileoption("nc","DefineMode",True)
if (isfilepresent(outputfile)) then
        system("rm " + outputfile)
 end if

fout=addfile(outputfile,"c")

;Define dimensions:

ncountry = 237
dim_names = (/"country"/)
;time dimension is unlimited, but currently set to 1.
dim_sizes = (/ncountry/)
dim_unlimited = (/False/)

print("Defining dimension sizes to be " + dim_names + dim_sizes)
filedimdef(fout,dim_names,dim_sizes,dim_unlimited)

;Define global attributes

fAtt=True
fAtt@title="average 10 yr"
fAtt@timestamp=systemfunc("date")

fileattdef(fout,fAtt)

;;;;;Define file variables:
filevardef(fout,"country","double","country")
filevardef(fout,"production","double",(/"country"/))

;;;;;Define variable attributes:

cntrtts=True
cntrtts@long_name="Country ID"
cntrtts@units=""
filevarattdef(fout,"country",cntrtts)

pctts=True
pctts@long_name="National production"
pctts@units="tons"
filevarattdef(fout,"production",pctts)

;Create Coordinate arrays:
fout->country=(/IDtxt/)

;write out the data
fout->production=(/output(1,:)/)


end
