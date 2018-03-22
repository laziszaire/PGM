function [assign,index] = assignments_F(F)
index = 1:prod(F.card);
assign =  IndexToAssignment(index,F.card);
end