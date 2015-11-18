
package ST46;
use  strict;

my %flat;
my $q = new CGI;
my $student	= $q->param('student');
my $act = $q->param('act');
my $dbh;

sub st46 {

	my ($q, $global) = @_;
	print $q->header(-type=>"text/html",-charset=>"windows-1251");
	print "<a href=\"$global->{selfurl}\">� ������ ������������</a>";
	
	print "<br><a href=\"$global->{selfurl}?student=$student&act=show\">������ �������</a>
	<br><a href=\"$global->{selfurl}?student=$student&act=FormAdd\">�������� ������</a>
	<br><a href=\"$global->{selfurl}?student=$student&act=FormEdit1\">������������� ������</a>
	<br><a href=\"$global->{selfurl}?student=$student&act=FormDelete\">������� ������</a>
	<br><a href=\"$global->{selfurl}?student=$student&act=FromDbm\">�������� ������ �� DBM-�����</a>";
	
	$dbh = DBI->connect("DBI:mysql:database=mydata;host=localhost","root", "root", {'RaiseError' => 1, 'AutoCommit' => 1});
	$dbh->do("SET NAMES cp1251");
	
	my %func = (
	"FormAdd" => \&FormAdd,
	"FormEdit1" => \&FormEdit1,
	"FormDelete" => \&FormDelete,
	"add" => \&add,
	"FormEdit2" => \&FormEdit2,
	"delete" => \&delete,
	"edit" => \&edit,
	"show" => \&show,
	"FromDbm" => \&FromDbm);
	
	if ($act eq 'FromDbm')
	{
		FromDbm();
		show();
	} else {if ($func{$act}) 
	{
		loadDB();
		$func{$act}->(); 
	}	else {
		loadDB();
		show();	
		}
	}
	 
	$dbh->disconnect();
}

 

sub FormAdd 
{
	print "<form method = 'get'>
	<input type = 'hidden' name = 'student' value = '$student'/>
	<input type='hidden' name='act' value='add'>
	<p>����� ��������:
	<input required type = 'number' name = 'number' min='1'<br>
	<p>���������� �����������:
	<input type = 'text' name = 'men'> <br>
	<p>���������� ������:
	<input type = 'text' name = 'room'><br>
	<p>������� �����������:
	<input type = 'text' name = 'secondname'><br>
	<p>������ � �������� �����?<input type='checkbox' name='sovet'><br>
	<p>�������:
	<input type = 'text' name = 'telephone'><br>
	<p><input type = 'submit' value = 'Add'></form>";
}

sub add 
{
	my $num = $q->param('number'); 
	my $men = $q->param('men');
	my $room = $q->param('room');
	my $secondname = $q->param('secondname');
	my $sovet = $q->param('sovet');
	my $telephone = $q->param('telephone');
	if (!exists $flat{$num})
	{
	if (defined $q->param('sovet'))
	{
		$sovet = "��";
	} else
	{
		$sovet = "���";
		$telephone = "-";
	}
	my $sth = $dbh->prepare("insert into dataflat (num,men,room,secondname,sovet,telephone) values (?,?,?,?,?,?)");
	$sth->execute($num,$men,$room,$secondname,$sovet,$telephone);
	$sth->finish();
	loadDB();
	show();	
	}
	else
	{
	print "<p>!Flat with this number already exists!";
	}
}

sub FormEdit1 
{
	print "<form method='post'>
	<input type = 'hidden' name = 'student' value = '$student'/>
	<input type='hidden' name='act' value='FormEdit2'>
	<p>�������� ����� ��������<br>
	<select name='number' size='5'>";
	
	foreach my $num (sort {$a<=>$b} keys %flat )
	{
	print "<option value='$num'>$num</option>";
	}
	print "</select>
	<p><input type='submit' value='Edit'></form>";
}


sub FormEdit2 
{
	my $num = $q->param('number');
	chomp($num);
	if (exists $flat{$num})
	{
	print "<form method='get'>
	<input type = 'hidden' name = 'student' value = '$student'/>
	<input type='hidden' name='act' value='edit'>
	<p>����� ��������:
	<input type = 'number' name = 'number' value='$num' readonly><br>
	<p>���������� �����������:
	<input type = 'text' name = 'men' value='$flat{$num}->{Men}'> <br>
	<p>���������� ������:
	<input type = 'text' name = 'room' value='$flat{$num}->{Room}'><br>
	<p>������� �����������:
	<input type = 'text' name = 'secondname' value='$flat{$num}->{Secondname}'><br>";
	if ($flat{$num}->{Sovet} eq '��')
	{
	print "<p>������ � �������� �����?<input type='checkbox' name='sovet' checked><br>
	<p>�������:
	<input type = 'text' name = 'telephone' value='$flat{$num}->{Telephone}'><br>
	<p><input type = 'submit' value = 'Edit'></form>";
	} else {
	print "<p>������ � �������� �����?<input type='checkbox' name='sovet'><br>
	<p>�������:
	<input type = 'text' name = 'telephone' value=''><br>
	<p><input type = 'submit' value = 'Edit'></form>";
	}
	}
	else 
	{
	print "<p>Mistake!Choose number of apartments for editing" ;} 
}


sub edit 
{
	my $num = $q->param('number');
	my $men = $q->param('men');
	my $room = $q->param('room');
	my $secondname = $q->param('secondname');
	my $sovet = $q->param('sovet');
	my $telephone = $q->param('telephone');
	if (defined $q->param('sovet'))
	{
		$sovet = "��";
		
	} else
	{
		$sovet = "���";
		$telephone = "-";
	}
	my $sth = $dbh->prepare( "update dataflat set men = ?, room=?, secondname=?, sovet=?, telephone=? where num=?");
	$sth->bind_param(1,$men);
	$sth->bind_param(2,$room);
	$sth->bind_param(3,$secondname);
	$sth->bind_param(4,$sovet);
	$sth->bind_param(5,$telephone);
	$sth->bind_param(6,$num);
	$sth->execute();
	$sth->finish();
	loadDB();
	show();	
}

 sub show 
 {
	my ($q, $global) = @_;
	
	print "<table><tr bgcolor = #DDDDDD>
    <th>Number</th><th>Men</th><th>Room</th><th>Secondname</th><th>Sovet</th><th>Telephone</th></tr>";
	
	foreach my $num (sort {$a<=>$b} keys %flat )
	{
	print "<tr><td>$num</td>";
		foreach my $val (sort keys %{$flat{$num}})
		{
		print"<td>$flat{$num}->{$val}</td>";
		}
    }	
	print "</table>";
	
 }

sub FormDelete 
{
	print "<form method='post'>
	<input type = 'hidden' name = 'student' value = '$student'/>
	<input type='hidden' name='act' value='delete'>
	<p>�������� ����� ��������<br>
	<select name='number' size='5'>";
	foreach my $num (sort {$a<=>$b} keys %flat )
	{
	print "<option value='$num'>$num</option>";
	}
    print "</select>
	<p><input type='submit' value='Delete'></form>";

}
sub delete 
{
	my $num = $q->param('number');
	chomp($num);
	if (exists $flat{$num})
	{
	my $sth = $dbh->prepare("delete from dataflat where num = ?");
	$sth->execute($num);
	$sth->finish();
	loadDB();
	show();
	}
	else
	{print "<p>Mistake!Choose number of apartments for deleting" ;}
}

sub loadDB
{
	%flat=();
	my $sth = $dbh->prepare("select * from dataflat");
	$sth->execute();
	while (my $myref = $sth->fetchrow_hashref())
	{
		my $val={
			Men=>$myref->{men},
			Room=>$myref->{room},
			Secondname => $myref->{secondname},
			Sovet => $myref->{sovet},
			Telephone => $myref->{telephone}
		};
		$flat{$myref->{num}}=$val;
	};
	$sth->finish();

};



 sub FromDbm
 {
    my %hash=();
	dbmopen(my %hash, "dbm", 0644);
	%flat=();
	$dbh->do("truncate table dataflat");
	my $sovet = $q->param('sovet');
	my $telephone = $q->param('telephone');
	while ((my $num,my $value) = each(%hash))
	{
	my @val=split(/<>/,$hash{$num});
	$flat{$num}={Men => "$val[0]", Room => "$val[1]",Secondname => "$val[2]",Sovet => "$sovet", Telephone=> "$telephone"}; 
	my $sth = $dbh->prepare("insert into dataflat (num,men,room,secondname,sovet,telephone) values (?,?,?,?,?,?)");
	$sth->execute($num,$val[0],$val[1],$val[2],$sovet,$telephone);
	$sth->finish();
	}
	dbmclose(%hash);
 }
 
 return 1;