# The purpose of this class is to provide a simple capability for validating
# domain names represented in ASCII, a feature that seems to be missing or
# obscured in other more wide-ranging domain-related gems.

class DomainNameValidator
  # Validates the proper formatting of a normalized domain name, i.e. - a
  # domain that is represented in ASCII. Thus, international domain names are
  # supported and validated, if they have undergone the required IDN
  # conversion to ASCII. The validation rules are:
  #
  # 1. The maximum length of a domain name is 253 characters.
  # 2. A domain name is divided into "labels" separated by periods. The maximum
  #    number of labels (including the top-level domain as a label) is 127.
  # 3. The maximum length of any label within a domain name is 63 characters.
  # 4. No label, including top-level domains, can begin or end with a dash.
  # 5. Top-level names cannot be all numeric.
  # 6. A domain name cannot begin with a period.

  def validate(dn, errs = [])
    errs.clear   # Make sure the array starts out empty
    if dn.nil?
      errs << ERRS[:zero_size]
    else
      dn = dn.strip
      errs << ERRS[:zero_size] if dn.size == 0
    end

    if errs.size == 0
      errs << ERRS[:max_domain_size] if dn.size > MAX_DOMAIN_LENGTH
      parts = dn.downcase.split('.')
      errs << ERRS[:max_level_size] if parts.size > MAX_LEVELS
      errs << ERRS[:min_level_size] if parts.size < MIN_LEVELS
      parts.each do |p|
        errs << ERRS[:max_label_size] if p.size > MAX_LABEL_LENGTH
        errs << ERRS[:label_dash_begin] if p[0] == '-'
        errs << ERRS[:label_dash_end] if p[-1] == '-'
        errs << ERRS[:illegal_chars] unless p.match(/^[a-z0-9\-\_]+$/)
      end
      errs << ERRS[:bogus_tld] unless File.readlines(TLD_FILE).map{
        |line| line.chomp }.include?(parts.last)
      errs << ERRS[:illegal_start] if parts.first[0] == '.'
    end

    errs.size == 0   # TRUE if valid, FALSE otherwise
  end
end
