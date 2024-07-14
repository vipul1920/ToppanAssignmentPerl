#!/usr/bin/perl
use strict;
use warnings;
use XML::Writer;
use IO::File;

# Input and output files
my $input_file = 'C:/Users/Vipul Potdar/Desktop/Toppan Photomask Task/orderform.txt';
my $output_file = 'C:/Users/Vipul Potdar/Desktop/Toppan Photomask Task/generated_output.xml';

# Open the input file
open(my $in, '<', $input_file) or die "Cannot open $input_file: $!";

# Read the entire input file
my @lines = <$in>;
close($in);

# Create a new XML writer
my $output = IO::File->new(">$output_file");
my $writer = XML::Writer->new(OUTPUT => $output, DATA_MODE => 1, DATA_INDENT => 2);

# Print XML header and root element
$writer->xmlDecl("UTF-8");
$writer->startTag("OrderForm");

# Variables to store data
my $customer_name = "!CUSTOMER_NAME__!!";
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
my $device = "";           
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
        $date = "$3-$1-$2"; 
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
    if ($line =~ /DEVICE\s*:\s*(.+?)\s*\|/) {
        $device = $1;
        $device =~ s/\s+$//;  
    }
    if ($line =~ /TECHNOLOGY NAME : (.+?)\s+STATUS\s*:/) {
        $technology_name = $1;
    }
    if ($line =~ /STATUS\s*:\s*(N0)/) {
        $status = $1;
    }
    if ($line =~ /MASK SET NAME : (\w+)/) {
        $mask_set_name = $1;
    }
    if ($line =~ /FAB UNIT\s*:\s*(.+?)\s+EMAIL\s*:/s) {
        $fab_unit = $1;
        $fab_unit =~ s/\s+$//;  
    }
    if ($line =~ /EMAIL : (\S+)/) {
        $email_address = $1;
    }
    if ($line =~ /LEVEL\s+MASK CODIFICATION\s+GRP\s+CYCL\s+QTY\s+SHIP DATE/) {
        next; # Skip the header line
    }
    if ($line =~ /(\d+)\s*\|\s*(.+?)\s*\|\s*(\d+)\s*\|\s*(\w+)\s*\|\s*(\d+)\s*\|\s*(\d{2})([A-Z]{3})(\d{2})/) {
        my $num = $1;
        my $mask_codification = $2 =~ s/\s+$//r; 
        my $group = $3;
        my $cycle = $4;
        my $quantity = $5;
        my $day = $6;
        my $month = $months{$7};
        my $year = "20$8";
        my $ship_date = "$year-$month-$day";
        my %level = (
            num => $num,
            mask_codification => $mask_codification,
            group => $group,
            cycle => $cycle,
            quantity => $quantity,
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
    if ($line =~ /SITE TO SEND INVOICE TO : (\w+ SITE)/) {
        $site_to_send_invoice_to = $1;
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

# Write XML content using XML::Writer
$writer->startTag("Customer");
$writer->characters($customer_name);
$writer->endTag("Customer");

$writer->startTag("Device");
$writer->characters($device);
$writer->endTag("Device");

$writer->startTag("MaskSupplier");
$writer->characters($mask_supplier);
$writer->endTag("MaskSupplier");

$writer->startTag("Date");
$writer->characters($date);
$writer->endTag("Date");

$writer->startTag("SiteOf");
$writer->characters($site_of);
$writer->endTag("SiteOf");

$writer->startTag("OrderFormNumber");
$writer->characters($orderform_number);
$writer->endTag("OrderFormNumber");

$writer->startTag("Revision");
$writer->characters($revision);
$writer->endTag("Revision");

$writer->startTag("Page");
$writer->characters($page);
$writer->endTag("Page");

$writer->startTag("TechnologyName");
$writer->characters($technology_name);
$writer->endTag("TechnologyName");

$writer->startTag("Status");
$writer->characters($status);
$writer->endTag("Status");

$writer->startTag("MaskSetName");
$writer->characters($mask_set_name);
$writer->endTag("MaskSetName");

$writer->startTag("FabUnit");
$writer->characters($fab_unit);
$writer->endTag("FabUnit");

$writer->startTag("EmailAddress");
$writer->characters($email_address);
$writer->endTag("EmailAddress");

$writer->startTag("Levels");
foreach my $level (@levels) {
    $writer->startTag("Level", "num" => $level->{num});
    $writer->startTag("MaskCodification");
    $writer->characters($level->{mask_codification});
    $writer->endTag("MaskCodification");
    $writer->startTag("Group");
    $writer->characters($level->{group});
    $writer->endTag("Group");
    $writer->startTag("Cycle");
    $writer->characters($level->{cycle});
    $writer->endTag("Cycle");
    $writer->startTag("Quantity");
    $writer->characters($level->{quantity});
    $writer->endTag("Quantity");
    $writer->startTag("ShipDate");
    $writer->characters($level->{ship_date});
    $writer->endTag("ShipDate");
    $writer->endTag("Level");
}
$writer->endTag("Levels");

$writer->startTag("Cdinformation");
foreach my $cd (@cdinfo) {
    $writer->startTag("Level");
    $writer->startTag("Revision");
    $writer->characters($cd->{revision});
    $writer->endTag("Revision");
    $writer->startTag("CDNumber");
    $writer->characters($cd->{cd_number});
    $writer->endTag("CDNumber");
    $writer->startTag("CDName");
    $writer->characters($cd->{cd_name});
    $writer->endTag("CDName");
    $writer->startTag("Feature");
    $writer->characters($cd->{feature});
    $writer->endTag("Feature");
    $writer->startTag("Tone");
    $writer->characters($cd->{tone});
    $writer->endTag("Tone");
    $writer->startTag("Polarity");
    $writer->characters($cd->{polarity});
    $writer->endTag("Polarity");
    $writer->endTag("Level");
}
$writer->endTag("Cdinformation");

$writer->startTag("PONumbers");
$writer->characters($po_numbers);
$writer->endTag("PONumbers");

$writer->startTag("SiteToSendMasksTo");
$writer->characters($site_to_send_masks_to);
$writer->endTag("SiteToSendMasksTo");

$writer->startTag("SiteToSendInvoiceTo");
$writer->characters($site_to_send_invoice_to);
$writer->endTag("SiteToSendInvoiceTo");

$writer->startTag("TechnicalContact");
$writer->characters($technical_contact);
$writer->endTag("TechnicalContact");

$writer->startTag("ShippingMethod");
$writer->characters("");
$writer->endTag("ShippingMethod");

$writer->startTag("AdditionalInformation");
$writer->characters("");
$writer->endTag("AdditionalInformation");

$writer->endTag("OrderForm");

# Close the writer
$writer->end();
$output->close();

print "XML file generated successfully as $output_file.\n";
