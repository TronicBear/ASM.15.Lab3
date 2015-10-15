#!perl.exe -w
package ST30;
use strict;
use CGI;
use DBI;
use Data::Dump qw(dump);

sub st30
{
	my ($q, $global) = @_;
	print $q->header(
		-type=>"text/html",
		-charset=>"windows-1251"
	);
	my $dbh = DBI->connect("DBI:mysql:database=lab3;host=localhost","root", "", {'RaiseError' => 1, 'AutoCommit' => 1});
	$dbh->do("SET NAMES cp1251");

	sub show_form
	{
		my $hidden_param = "";
		my $name = $q->param('name');
		my $phone = $q->param('phone');
		my $business_phone = $q->param('business_phone');
		my $type = '�������';
		my $additional_field = "";
		if($q->param('type') eq 'business') 
		{
			$type = '�������';
			$additional_field = "<p>������� �����:&nbsp<input type=\"text\" name=\"business_phone\"  value=\"$business_phone\"></p>";
		}
		my $action = "add";
		my $title = "�������� $type ������:";
		if($q->param('action') eq 'to_edit') 
		{
			my $id = $q->param('id');
			$hidden_param = "<input type=\"hidden\" name=\"id\" value=\"$id\">";
			$action = "update";
			$title = "������������� $type ������";
		}
		print "<form method=\"post\">
		  	<p><h2>$title</h2></p>
		  	$hidden_param
		  	<input type=\"hidden\" name=\"type\" value=\"".$q->param('type')."\">
		  	<input type=\"hidden\" name=\"student\" value=\"".$global->{student}."\">
		  	<p>���:&nbsp<input type=\"text\" name=\"name\" value=\"$name\"></p>
		  	<p>����� ��������:&nbsp<input type=\"text\" name=\"phone\" value=\"$phone\"></p>
		  	$additional_field
	  		<p><button name=\"action\" type=\"submit\" value=\"$action\">���������</button></p>
	 	</form><hr>";
	}

	sub validate 
	{
		my ($type, $query, $name, $phone, $business_phone, $id) = @_;
		if(
			($type eq "simple" and ($name ne "") and ($phone ne "") )|| 
			($type eq "business" and ($name ne "") and ($phone ne "") and ($business_phone ne ""))
		)
		{
			$dbh->do($query, undef, $name, $phone, $business_phone, $id);
		}
		else 
		{
			print "<b>��� ���� ����������� ��� ����������!</b>";
		}
	}

	my %commands = (
		'import' => sub {
			my %buffer;
			dbmopen(%buffer, $q->param('file'), 0644);
			if($q->param('clear') eq "yes")
			{
				$dbh->do("DELETE FROM st30");
			}		
			while ( my ($key, $value) = each %buffer )
			{
				my ($name, $phone) = split(/--/, $value);
				validate(
					"simple",
					"INSERT INTO st30 (name,phone) VALUES (?,?)",
					$name, 
					$phone
				);
			}
			dbmclose(%buffer);
		},
		'create' => sub {
			show_form();
		},
		'to_edit' => sub {
			show_form();
		},
		'update' => sub {
			validate(
				$q->param('type'),
				"UPDATE st30 SET name=?, phone=?, business_phone=? WHERE id = ?",
				$q->param('name'), 
				$q->param('phone'), 
				((defined $q->param('business_phone')) ? $q->param('business_phone') : ""),
				$q->param('id')
			);
		},
		'delete' => sub {
			$dbh->do("DELETE FROM st30 WHERE id = ?", undef, $q->param('id'));
		},
		'add' => sub {
			validate(
				$q->param('type'),
				"INSERT INTO st30 (name,phone,business_phone) VALUES (?,?,?)",
				$q->param('name'),
				$q->param('phone'),
				((defined $q->param('business_phone')) ? $q->param('business_phone') : "")
			);

		}
	);

	my $command = $q->param('action');
	if (defined $commands{$command}) 
	{
		$commands{$command}->();	
	}

	sub show_table
	{
		my $table_header = "<table>
			<tr colspan = 999><h1>���������� �����</h1></tr>
			<tr colspan = 999><form method=\"post\">
				<input type=\"hidden\" name=\"student\" value=\"".$global->{student}."\">
				<input type=\"checkbox\" value=\"yes\" name=\"clear\" checked>�������� �� ����� ���������������&nbsp;&nbsp;&nbsp;
   				<input type=\"text\" name=\"file\">
   				<button name=\"action\" type=\"submit\" value=\"import\">��������� �� �����</button>
  			</form></tr>";
		my $table_content = "";
		my $sth = $dbh->prepare("SELECT * FROM st30");
		$sth->execute();
	  	while (my $ref = $sth->fetchrow_hashref()) 
	  	{
	  		my $style = "";
	  		my $type = 'simple';
	  		if($ref->{business_phone} ne "") 
	  		{
	  			$type = 'business';
	  			$style = "style=\"background: #f0fff0;\"";
	  		}
	    	$table_content .= "<tr $style>
				<form method=\"post\">
					<input type=\"hidden\" name=\"student\" value=\"".$global->{student}."\">
					<input type=\"hidden\" name=\"id\" value=\"".$ref->{id}."\">
					<input type=\"hidden\" name=\"type\" value=\"$type\">
					<input type=\"hidden\" name=\"name\" value=\"".$ref->{name}."\">
			  		<input type=\"hidden\" name=\"phone\" value=\"".$ref->{phone}."\">
			  		<input type=\"hidden\" name=\"business_phone\" value=\"".$ref->{business_phone}."\">
			  		<td>".$ref->{name}."</td>
			  		<td>".$ref->{phone}."</td>
			  		<td>".$ref->{business_phone}."</td>
			  		<td>
			  			<button name=\"action\" type=\"submit\" value=\"to_edit\">�������������</button>
			  			<button name=\"action\" type=\"submit\" value=\"delete\">�������</button>
			  		</td>
			 	</form>
			</tr>";
	  	}
	  	$sth->finish();
	  	if($table_content)
	  	{
	  		print "$table_header<tr>
					<td><b>���</b></td>
				 	<td><b>�������</b></td>
				 	<td><b>������� �������</b></td>
				</tr>$table_content</table>";
	  	}
	  	else
	  	{
	  		print "$table_header
	  			<tr colspan = 999><p><b>���������� ����� �����! �������� ���� �� ���� ������, ��������� �����, ��� ������������ ������ �� dbm-�����</b></tr>
	  		</table>";
	  	}		
	}

	show_table();

	print "<hr><form method=\"post\">
		  	<p><h2>�������� ��� ������:</h2></p>
		  	<input type=\"hidden\" name=\"student\" value=\"".$global->{student}."\">
		  	<p><select name=\"type\">
    			<option value=\"simple\">�������</option>
    			<option value=\"business\">�������</option>
   			</select></p>
	  		<p><button name=\"action\" type=\"submit\" value=\"create\">������� � ��������</button></p>
	 	</form>";

	print '<hr><a href="'.$global->{selfurl}.'">����� � ����</a>';
	$dbh->disconnect();
}

1;



