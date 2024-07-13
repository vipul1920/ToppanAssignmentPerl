#!/usr/bin/perl
use strict;
use warnings;

# Input and output files
my $input_file = 'C:/Users/Vipul Potdar/Desktop/Toppan Photomask Task/orderform.txt';
my $output_file = 'C:/Users/Vipul Potdar/Desktop/Toppan Photomask Task/generated_output_Perl.xml';

# Open the input file
open(my $in, '<', $input_file) or die "Cannot open $input_file: $!";

# Read the entire input file
my @lines = <$in>;
close($in);

# Open the output file
open(my $out, '>', $output_file) or die "Cannot open $output_file: $!";

# Print XML header
print $out "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
print $out "<OrderForm>\n";

# Variables to store data
my $customer_name = "!CUSTOMER_NAME__!!";  # Initialize with default value Customer Name 
my $mask_supplier = "";
my $date = "";
my $site_of = "";
my $orderform_number = "";
my $revision = "";
my $page = "";
my $technology_name = "";  
my $status = "";           
my $mask_set_name = "";
my $fab_unit = "";         
my $email_address = "";
my @levels = ();
my @cdinfo = ();
my $po_numbers = "";
my $site_to_send_masks_to = "";
my $site_to_send_invoice_to = "";
my $technical_contact = "";

# Hash to map month abbreviations to numbers
my %months = (
    'JAN' => '01', 'FEB' => '02', 'MAR' => '03', 'APR' => '04',
    'MAY' => '05', 'JUN' => '06', 'JUL' => '07', 'AUG' => '08',
    'SEP' => '09', 'OCT' => '10', 'NOV' => '11', 'DEC' => '12'
);

# Parse the input file content
foreach my $line (@lines) {
    chomp($line);
    if ($line =~ /MASK SUPPLIER : (\w+)/) {
        $mask_supplier = $1;
    }
    if ($line =~ /DATE : (\d{2})\/(\d{2})\/(\d{4})/) {
        $date = "$3-$1-$2"; # Convert date format to YYYY-MM-DD
    }
    if ($line =~ /SITE OF : (\w+)/) {
        $site_of = $1;
    }
    if ($line =~ /ORDERFORM NUMBER : (IP \d+)/) {
        $orderform_number = $1;
    }
    if ($line =~ /REVISION : (\d+)/) {
        $revision = $1;
    }
    if ($line =~ /PAGE : (\d+)/) {
        $page = $1;
    }
    if ($line =~ /TECHNOLOGY NAME : (.+?)\s+STATUS\s*:/) {
        $technology_name = $1;
    }
    if ($line =~ /STATUS\s*:\s*(\S+)/) {
        $status = $1;
    }
    if ($line =~ /MASK SET NAME : (\w+)/) {
        $mask_set_name = $1;
    }
    if ($line =~ /FAB UNIT : (\w+)/) {
        $fab_unit = $1;
    }
    if ($line =~ /EMAIL : (\S+)/) {
        $email_address = $1;
    }
    if ($line =~ /LEVEL\s+MASK CODIFICATION\s+GRP\s+CYCL\s+QTY\s+SHIP DATE/) {
        next; # Skip the header line
    }
    if ($line =~ /(\d+)\s*\|(.+?)\|\s*(\d+)\s*\|\s*(\w+)\s*\|\s*(\d+)\s*\|\s*(\d{2})([A-Z]{3})(\d{2})/) {
        my $day = $6;
        my $month = $months{$7};
        my $year = "20$8";
        my $ship_date = "$year-$month-$day";
        my %level = (
            num => $1,
            mask_codification => $2 =~ s/\s+$//r, # Remove trailing spaces
            group => $3,
            cycle => $4,
            quantity => $5,
            ship_date => $ship_date,
        );
        push @levels, \%level;
    }
    if ($line =~ /P\.O\. NUMBERS : (\S+)/) {
        $po_numbers = $1;
    }
    if ($line =~ /SITE TO SEND MASKS TO : (\w+)/) {
        $site_to_send_masks_to = $1;
    }
    if ($line =~ /SITE TO SEND INVOICE TO : (.+)/) {
        ($site_to_send_invoice_to) = $line =~ /SITE TO SEND INVOICE TO : (\w+ SITE)/;
    }
    if ($line =~ /TECHNICAL CONTACT : (.+?)\s+/) {
        $technical_contact = $1;
    }
    if ($line =~ /(\d+)\s*\|\s*(\w+)\s*\|\s*(\w+)\s*\|\s*(\w+)\s*\|\s*(\d+\.\d+)\s*\|\s*(\d+\.\d+)\s*\|\s*(\d+)\s*\|\s*(\w+)\s*\|\s*(\w+)\s*\|\s*(\w+)\s*\|\s*(\w+)\s*\|\s*(\w+)\s*\|\s*(\w+)\s*\|\s*(\w+)/) {
        my %cd = (
            revision => $2,
            cd_number => $7,
            cd_name => $8,
            feature => $9,
            tone => $10,
            polarity => $11,
        );
        push @cdinfo, \%cd;
    }
}

# Print data in XML format
print $out "  <Customer>", (defined $customer_name ? $customer_name : ''), "</Customer>\n";
print $out "  <Device>AA\@BBBBB</Device>\n";
print $out "  <MaskSupplier>", (defined $mask_supplier ? $mask_supplier : ''), "</MaskSupplier>\n";
print $out "  <Date>", (defined $date ? $date : ''), "</Date>\n";
print $out "  <SiteOf>", (defined $site_of ? $site_of : ''), "</SiteOf>\n";
print $out "  <OrderFormNumber>", (defined $orderform_number ? $orderform_number : ''), "</OrderFormNumber>\n";
print $out "  <Revision>", (defined $revision ? $revision : ''), "</Revision>\n";
print $out "  <Page>", (defined $page ? $page : ''), "</Page>\n";
print $out "  <TechnologyName>", (defined $technology_name ? $technology_name : ''), "</TechnologyName>\n";
print $out "  <Status>", (defined $status ? $status : ''), "</Status>\n";
print $out "  <MaskSetName>", (defined $mask_set_name ? $mask_set_name : ''), "</MaskSetName>\n";
print $out "  <FabUnit>", (defined $fab_unit ? $fab_unit : ''), "</FabUnit>\n";
print $out "  <EmailAddress>", (defined $email_address ? $email_address : ''), "</EmailAddress>\n";
print $out "  <Levels>\n";
foreach my $level (@levels) {
    print $out "    <Level num=\"$level->{num}\">\n";
    print $out "      <MaskCodification>", (defined $level->{mask_codification} ? $level->{mask_codification} : ''), "</MaskCodification>\n";
    print $out "      <Group>", (defined $level->{group} ? $level->{group} : ''), "</Group>\n";
    print $out "      <Cycle>", (defined $level->{cycle} ? $level->{cycle} : ''), "</Cycle>\n";
    print $out "      <Quantity>", (defined $level->{quantity} ? $level->{quantity} : ''), "</Quantity>\n";
    print $out "      <ShipDate>", (defined $level->{ship_date} ? $level->{ship_date} : ''), "</ShipDate>\n";
    print $out "    </Level>\n";
}
print $out "  </Levels>\n";

print $out "  <Cdinformation>\n";
foreach my $cd (@cdinfo) {
    print $out "    <Level>\n";
    print $out "      <Revision>", (defined $cd->{revision} ? $cd->{revision} : ''), "</Revision>\n";
    print $out "      <CDNumber>", (defined $cd->{cd_number} ? $cd->{cd_number} : ''), "</CDNumber>\n";
    print $out "      <CDName>", (defined $cd->{cd_name} ? $cd->{cd_name} : ''), "</CDName>\n";
    print $out "      <Feature>", (defined $cd->{feature} ? $cd->{feature} : ''), "</Feature>\n";
    print $out "      <Tone>", (defined $cd->{tone} ? $cd->{tone} : ''), "</Tone>\n";
    print $out "      <Polarity>", (defined $cd->{polarity} ? $cd->{polarity} : ''), "</Polarity>\n";
    print $out "    </Level>\n";
}
print $out "  </Cdinformation>\n";

print $out "  <PONumbers>", (defined $po_numbers ? $po_numbers : ''), "</PONumbers>\n";
print $out "  <SiteToSendMasksTo>", (defined $site_to_send_masks_to ? $site_to_send_masks_to : ''), "</SiteToSendMasksTo>\n";
print $out "  <SiteToSendInvoiceTo>", (defined $site_to_send_invoice_to ? $site_to_send_invoice_to : ''), "</SiteToSendInvoiceTo>\n";
print $out "  <TechnicalContact>", (defined $technical_contact ? $technical_contact : ''), "</TechnicalContact>\n";
print $out "  <ShippingMethod></ShippingMethod>\n";
print $out "  <AdditionalInformation></AdditionalInformation>\n";
print $out "</OrderForm>\n";

# Close the file handles
close($in);
close($out);

print "XML file generated successfully as $output_file.\n";
