function model=lineF(x,y)

M=[x; ones(1,size(x,2))]';
B=y';
model=M'*M\(M'*B);





